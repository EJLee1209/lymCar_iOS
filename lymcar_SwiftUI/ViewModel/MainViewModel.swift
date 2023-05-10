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

enum SearchResult {
    case idle
    case loading
    case success(SearchKeywordResult)
    case failure(String)
}

enum Progress {
    case idle
    case loading
}

extension SearchResult : Equatable {
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle): return true
        case (.loading, .loading): return true
        case (.success(let lhsValue), .success(let rhsValue)):
            return lhsValue.documents == rhsValue.documents
        case (.failure(let lhsMsg), .failure(let rhsMsg)):
            return lhsMsg == rhsMsg
        default: return false
        }
    }
}

class MainViewModel: ObservableObject {
    @Published var detectAnonymous: Bool = false
    @Published var searchResult: SearchResult = .idle
    @Published var myRoom: CarPoolRoom?
    @Published var progress: Progress = .idle
    private let kakaoApiUrl = Bundle.main.kakaoApiUrl
    private let kakaoApiKey = Bundle.main.kakaoApiKey
    private let auth = Firebase.Auth.auth()
    private let db = Firestore.firestore()
    private var moniteringRegistration: ListenerRegistration? = nil
    private var myRoomRegistration: ListenerRegistration? = nil
    private var userRegistration: ListenerRegistration? = nil
    
    
    deinit {
        removeRegistration()
    }
    
    func removeRegistration() {
        myRoomRegistration?.remove()
        moniteringRegistration?.remove()
        userRegistration?.remove()
        print("removed")
    }
    
    func moniteringLogged() {
        moniteringRegistration = db.collection(FireStoreTable.SIGNEDIN).document(auth.currentUser!.uid)
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
    
    func subscribeUser(completion: @escaping (Result<User?, FirestoreErrorCode>) -> Void) {
        guard let safeUser = auth.currentUser else { return }
        userRegistration = db.collection(FireStoreTable.USER).document(safeUser.uid)
            .addSnapshotListener { snapshot, error in
                if let safeError = error {
                    print(safeError.localizedDescription)
                    completion(.failure(FirestoreErrorCode(.cancelled)))
                    return
                }
                do {
                    let user = try snapshot?.data(as: User.self)
                    completion(.success(user))
                } catch{
                    print(error.localizedDescription)
                }
            }
    }
    
    func searchPlace(keyword: String) {
        let requestUrl = "\(kakaoApiUrl)?query=\(keyword)"
        
        let headers: HTTPHeaders = [
            "Authorization": kakaoApiKey
        ]
        
        AF.request(
            requestUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
            method: .get,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: headers
        )
            .responseDecodable(of: SearchKeywordResult.self) { response in
                switch response.result {
                case .success(let searchResult):
                    self.searchResult = .success(searchResult)
                case .failure(let error):
                    self.searchResult = .failure(error.localizedDescription)
                
                }
            }
    }
    
    func subscribeMyRoom(completion: @escaping (Result<CarPoolRoom?, FirestoreErrorCode>) -> Void) {
        if let currentUser = auth.currentUser {
            myRoomRegistration = db.collection(FireStoreTable.ROOM)
                .whereField(FireStoreTable.FIELD_PARTICIPANTS, arrayContains: currentUser.uid)
                .addSnapshotListener({ snapshot, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    guard let data = snapshot?.documents.first else {
                        completion(.success(nil))
                        return
                    }
                    do {
                        let room = try data.data(as: CarPoolRoom.self)
                        completion(.success(room))
                    }
                    catch {
                        print(error)
                    }
                })
        }
    }
    
    func createRoom(room: CarPoolRoom, completion: @escaping (Result<CarPoolRoom, FirestoreErrorCode>) -> Void) {
        progress = .loading
        let ref = db.collection(FireStoreTable.ROOM).document()
        var copyRoom = room
        copyRoom.roomId = ref.documentID
        copyRoom.participants = [auth.currentUser!.uid]
        ref.setData(copyRoom.dictionary) { error in
            if let safeError = error {
                print(safeError.localizedDescription)
                completion(.failure(FirestoreErrorCode(.cancelled)))
                self.progress = .idle
                return
            }
            
            completion(.success(copyRoom))
            self.progress = .idle
        }
    }
    
    func getAllRoom(genderOption: String, completion: @escaping (Result<[CarPoolRoom], FirestoreErrorCode>) -> Void) {
        progress = .loading
        db.collection(FireStoreTable.ROOM)
            .whereField(FireStoreTable.FIELD_CLOSED, isEqualTo: false)
            .whereField(FireStoreTable.FIELD_GENDER_OPTION, in: [genderOption, Constants.GENDER_OPTION_NONE])
            .whereField(FireStoreTable.FIELD_DEPARTURE_TIME, isGreaterThanOrEqualTo: Utils.getCurrentDateTime())
            .getDocuments { querySnapshot, error in
                if let safeError = error {
                    print(safeError.localizedDescription)
                    completion(.failure(FirestoreErrorCode(.cancelled)))
                    self.progress = .idle
                    return
                }
                guard let safeQuery = querySnapshot else {
                    self.progress = .idle
                    completion(.success([]))
                    return
                }
                var rooms = [CarPoolRoom]()
                safeQuery.documents.forEach { queryDocumentSnapshot in
                    do {
                        let room = try queryDocumentSnapshot.data(as: CarPoolRoom.self)
                        rooms.append(room)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                self.progress = .idle
                completion(.success(rooms))
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
                completion(.success(""))
                DispatchQueue.main.async {
                    self.progress = .idle
                }
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
                self.db.collection(FireStoreTable.FCMTOKENS).document(safeUser.uid)
                    .updateData([
                        FireStoreTable.FIELD_ROOM_ID : ""
                    ])
                completion(.success(""))
                DispatchQueue.main.async {
                    self.progress = .idle
                }
            }
        }
    }
    
    func logout(completion: @escaping (Result<String, Error>) -> Void) {
        self.progress = .loading
        if let user = auth.currentUser {
            db.collection(FireStoreTable.FCMTOKENS).document(user.uid)
                .updateData([
                    FireStoreTable.FIELD_TOKEN : ""
                ])
            do {
                try auth.signOut()
                completion(.success(""))
                self.progress = .idle
            }catch {
                print("Error signOut : \(error)")
                completion(.failure(error))
                self.progress = .idle
            }
        } else {
            self.progress = .idle
        }
    }

}
