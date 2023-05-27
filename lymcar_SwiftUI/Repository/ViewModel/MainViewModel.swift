//
//  MainViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import Alamofire
import Combine

enum Progress {
    case idle
    case loading
}

class MainViewModel: ObservableObject {
    @Published var detectAnonymous: Bool = false
    @Published var myRoom: CarPoolRoom?
    @Published var progress: Progress = .idle
    @Published var currentUser: User?
    @Published var participantsTokens: [String:String] = [:]
    private let baseUrl = Bundle.main.baseUrl
    private let kakaoApiUrl = Bundle.main.kakaoApiUrl
    private let kakaoApiKey = Bundle.main.kakaoApiKey
    private let auth = Firebase.Auth.auth()
    private let db = Firestore.firestore()
    var moniteringRegistration: ListenerRegistration? = nil
    var myRoomRegistration: ListenerRegistration? = nil
    var participantsRegistration: ListenerRegistration? = nil
    
    deinit {
        removeAllRegistration()
    }
    
    func removeAllRegistration() {
        myRoomRegistration?.remove()
        moniteringRegistration?.remove()
        participantsRegistration?.remove()
    }
    
    func moniteringLogged() {
        guard let safeUser = auth.currentUser else { return }
        moniteringRegistration = db.collection(FireStoreTable.SIGNEDIN).document(safeUser.uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    return
                }
                let deviceId = snapshot.get(FireStoreTable.FIELD_DEVICEID) as! String
                
                if deviceId != Utils.getDeviceUUID() {
                    self.detectAnonymous = true
                }
            }
    }

    func subscribeMyRoom() {
        if let currentUser = auth.currentUser {
            myRoomRegistration = db.collection(FireStoreTable.ROOM)
                .whereField(FireStoreTable.FIELD_PARTICIPANTS, arrayContains: currentUser.uid)
                .addSnapshotListener({ snapshot, error in
                    if let error = error {
                        print(error)
                        self.myRoom = nil
                        return
                    }
                    guard let data = snapshot?.documents.first else {
                        self.myRoom = nil
                        return
                    }
                    do {
                        let room = try data.data(as: CarPoolRoom.self)
                        self.myRoom = room
                    }
                    catch {
                        self.myRoom = nil
                        print(error)
                    }
                })
        }
    }
    
    func subscribeParticipantsTokens(roomId: String) {
        self.participantsRegistration = db.collection(FireStoreTable.FCMTOKENS)
            .whereField(FireStoreTable.FIELD_ROOM_ID, isEqualTo: roomId)
            .addSnapshotListener({ snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                guard let document = snapshot?.documents else {
                    print("no participants")
                    return
                }
                
                self.participantsTokens = [:]
                document.forEach { data in
                    if let token = data.get(FireStoreTable.FIELD_TOKEN) as? String {
                        if let platform = data.get(FireStoreTable.FIELD_PLATFORM) as? String {
                            self.participantsTokens[token] = platform
                        }
                    }
                }
            })
    }
    
    @MainActor
    func getUser() async {
        guard let safeUser = auth.currentUser else { return }
        do {
            let snapshot = try await db.collection(FireStoreTable.USER).document(safeUser.uid)
                .getDocument()
            
            let user = try snapshot.data(as: User.self)
            self.currentUser = user
        }catch {
            print(error.localizedDescription)
            self.currentUser = nil
        }
    }
    
    @MainActor
    func getParticipantsTokens(roomId: String) async -> [String:String] {
        self.progress = .loading
        do {
            let snapshot = try await db.collection(FireStoreTable.FCMTOKENS)
                .whereField(FireStoreTable.FIELD_ROOM_ID, isEqualTo: roomId)
                .getDocuments()
            
            var participantsTokens : [String:String] = [:]
            snapshot.documents.forEach { data in
                if let token = data.get(FireStoreTable.FIELD_TOKEN) as? String {
                    if let platform = data.get(FireStoreTable.FIELD_PLATFORM) as? String {
                        participantsTokens[token] = platform
                    }
                }
            }
            self.progress = .idle
            return participantsTokens
        } catch {
            self.progress = .idle
            return [:]
        }
    }
    
    @MainActor
    func searchPlace(keyword: String) async -> [Place] {
        let requestUrl = "\(kakaoApiUrl)?query=\(keyword)"
        
        let headers: HTTPHeaders = [
            "Authorization": kakaoApiKey
        ]
        
        do {
            let result = try await AppNetworking.shared.requestJSON(requestUrl, type: SearchKeywordResult.self, method: .get, headers: headers)
            return result.documents
        }catch {
            print("searchPlace 에러발생 : \(error)")
            return []
        }
    }
    
    @MainActor
    func findUserName(uid: String) async -> String? {
        do {
            let document = try await db.collection(FireStoreTable.USER).document(uid)
                .getDocument()
            
            if let name = document.get(FireStoreTable.FIELD_NAME) as? String {
                return name
            } else {
                return nil
            }
            
        } catch {
            return nil
        }
    }
    
    @MainActor
    func deactivateRoom(roomId: String) async -> Bool {
        self.progress = .loading
        
        do {
            try await db.collection(FireStoreTable.ROOM).document(roomId)
                .updateData([
                    FireStoreTable.FIELD_CLOSED: true
                ])
            
            self.progress = .idle
            return true
        } catch {
            self.progress = .idle
            return false
        }
    }
    
    @MainActor
    func sendPushMessage(
        chat: Chat,
        receiveTokens: [String:String]
    ) async -> Bool {
        print("call sendPushMessage")
        print("participants : \(receiveTokens)")
        for (token, target) in receiveTokens {
            let requestUrl = "\(baseUrl)api/message/push?token=\(token)&id=\(chat.id)&roomId=\(chat.roomId)&userId=\(chat.userId)&userName=\(chat.userName)&message=\(chat.msg)&messageType=\(chat.messageType)&target=\(target)"

            do {
                let result = try await AppNetworking.shared.requestJSON(requestUrl, type: Bool.self, method: .post)
                if !result{
                    return false
                }
            }catch {
                print("sendPushMessage 에러 발생 : \(error)")
                return false
            }
        }
        return true
    }
    
    @MainActor
    func createRoom(room: CarPoolRoom) async -> Bool  {
        progress = .loading
        let ref = db.collection(FireStoreTable.ROOM).document()
        var copyRoom = room
        copyRoom.roomId = ref.documentID
        copyRoom.participants = [auth.currentUser!.uid]
        do {
            try await ref.setData(copyRoom.dictionary)
            try await self.db.collection(FireStoreTable.FCMTOKENS).document(self.auth.currentUser!.uid)
                .updateData([FireStoreTable.FIELD_ROOM_ID : copyRoom.roomId])
            progress = .idle
            self.myRoom = copyRoom
            return true
        } catch {
            progress = .idle
            self.myRoom = nil
            return false
        }
    }
    
    @MainActor
    func getAllRoom(genderOption: String) async -> [CarPoolRoom] {
        progress = .loading
        do {
            let querySnapshot = try await db.collection(FireStoreTable.ROOM)
                .whereField(FireStoreTable.FIELD_CLOSED, isEqualTo: false)
                .whereField(FireStoreTable.FIELD_GENDER_OPTION, in: [genderOption, Constants.GENDER_OPTION_NONE])
                .whereField(FireStoreTable.FIELD_DEPARTURE_TIME, isGreaterThanOrEqualTo: Utils.getCurrentDateTime())
                .getDocuments()
            
            var rooms = [CarPoolRoom]()
            querySnapshot.documents.forEach{ queryDocumentSnapshot in
                do {
                    let room = try queryDocumentSnapshot.data(as: CarPoolRoom.self)
                    rooms.append(room)
                } catch {
                    print("getAllRoom 에서 snapshot을 CarPoolRoom 객체로 변환 중 에러가 발생했습니다")
                }
            }
            self.progress = .idle
            return rooms
        }catch {
            return []
        }
    }
    
    func joinRoom(room: CarPoolRoom, completion: @escaping (Result<String, NSError>) -> Void) {
        guard let safeUser = auth.currentUser else {
            completion(.failure(
                NSError(
                    domain: "로그인 정보를 가져오지 못했습니다",
                    code: -1
                )
            ))
            return
        }
        
        if room.participants.contains(safeUser.uid) {
            // 이미 방에 속해있음
            completion(.success(""))
            return
        }
        progress = .loading
        let docRef = db.collection(FireStoreTable.ROOM).document(room.roomId)

        db.runTransaction { transaction, errorPointer in
            let roomDocument: DocumentSnapshot
            do {
                roomDocument = try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldCount = roomDocument.data()?[FireStoreTable.FIELD_USER_COUNT] as? Int else {
                let error = NSError(
                    domain: "채팅방 데이터를 가져오는 중에 에러가 발생했습니다",
                    code: -1
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard let closed = roomDocument.data()?[FireStoreTable.FIELD_CLOSED] as? Bool else {
                let error = NSError(
                    domain: "채팅방 데이터를 가져오는 중에 에러가 발생했습니다",
                    code: -1
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard var participants = roomDocument.data()?[FireStoreTable.FIELD_PARTICIPANTS] as? [String] else {
                let error = NSError(
                    domain: "채팅방 데이터를 가져오는 중에 에러가 발생했습니다",
                    code: -1
                )
                errorPointer?.pointee = error
                return nil
            }
            
            if oldCount >= room.userMaxCount {
                let error = NSError(
                    domain: "채팅방 인원 초과",
                    code: -1
                )
                errorPointer?.pointee = error
                return nil
            }
            if closed {
                let error = NSError(
                    domain: "마감된 채팅방",
                    code: -1
                )
                errorPointer?.pointee = error
                return nil
            }
            
            participants.append(safeUser.uid)
            transaction.updateData([FireStoreTable.FIELD_USER_COUNT : oldCount + 1], forDocument: docRef)
            transaction.updateData([FireStoreTable.FIELD_PARTICIPANTS : participants], forDocument: docRef)

            return nil
            
        } completion: { object, error in
            if let error = error {
                let nsError = error as NSError
                print("transaction failed: \(error)")
                completion(.failure(nsError))
                DispatchQueue.main.async {
                    self.progress = .idle
                }
            } else {
                // transaction successfully committed
                self.db.collection(FireStoreTable.FCMTOKENS).document(safeUser.uid)
                    .updateData([
                        FireStoreTable.FIELD_ROOM_ID : room.roomId
                    ])
                DispatchQueue.main.async {
                    self.progress = .idle
                }
                
                completion(.success(""))
            }
        }
    }
    
    func exitRoom(roomId: String, completion: @escaping (Result<String, FirestoreErrorCode>) -> Void) {
        guard let safeUser = auth.currentUser else {
            completion(.failure(FirestoreErrorCode(.unknown)))
            return
        }
        progress = .loading
        let docRef = db.collection(FireStoreTable.ROOM).document(roomId)
        
        db.runTransaction { transaction, errorPointer in
            let roomDocument: DocumentSnapshot
            do {
                roomDocument =  try transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let oldUserCount = roomDocument.data()?[FireStoreTable.FIELD_USER_COUNT] as? Int else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "채팅방 데이터를 가져오는 중에 에러가 발생했습니다"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            guard var oldParticipants = roomDocument.data()?[FireStoreTable.FIELD_PARTICIPANTS] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "채팅방 데이터를 가져오는 중에 에러가 발생했습니다"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            
            for i in 0 ..< oldParticipants.count {
                if oldParticipants[i] == safeUser.uid {
                    oldParticipants.remove(at: i)
                    break
                }
            }
            
            if oldUserCount == 1 {
                // 방 삭제하면 됨
                self.db.collection(FireStoreTable.ROOM).document(roomId).delete()
                completion(.success(""))
                DispatchQueue.main.async {
                    self.progress = .idle
                }
            } else {
                // 방 퇴장 처리
                transaction.updateData([FireStoreTable.FIELD_USER_COUNT : oldUserCount - 1], forDocument: docRef)
                transaction.updateData([FireStoreTable.FIELD_PARTICIPANTS : oldParticipants], forDocument: docRef)
            }
            return nil
        } completion: { object, error in
            if let error = error {
                print("transaction failed: \(error)")
                completion(.failure(FirestoreErrorCode(.cancelled)))
                DispatchQueue.main.async {
                    self.progress = .idle
                }
            } else {
                // transaction successfully committed
                self.progress = .idle
                
                self.db.collection(FireStoreTable.FCMTOKENS).document(safeUser.uid)
                    .updateData([
                        FireStoreTable.FIELD_ROOM_ID : ""
                    ])
                completion(.success(roomId))
            }
        }
    }
    
    @MainActor
    func logout() async -> Bool {
        self.progress = .loading
        if let user = auth.currentUser {
            do {
                try await db.collection(FireStoreTable.FCMTOKENS).document(user.uid)
                    .updateData([FireStoreTable.FIELD_TOKEN : ""])
                try auth.signOut()
                self.progress = .idle
                return true
            }catch {
                self.progress = .idle
                print("logout 에러 발생 : \(error)")
                return false
            }
        } else {
            return false
        }
    }
    
    func updateFcmToken(token: String) {
        guard let safeUser = auth.currentUser else { return }
        db.collection(FireStoreTable.FCMTOKENS).document(safeUser.uid)
            .updateData([
                FireStoreTable.FIELD_TOKEN : token,
                FireStoreTable.FIELD_PLATFORM : "ios"
            ])
    }
}
