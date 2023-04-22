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
                completion(.success(rooms))
            }
    }
}
