//
//  MainViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation
import Firebase
import Alamofire

enum SearchResult {
    case idle
    case loading
    case success(SearchKeywordResult)
    case failure(String)
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
    private let kakaoApiUrl = Bundle.main.kakaoApiUrl
    private let kakaoApiKey = Bundle.main.kakaoApiKey
    private let auth = Firebase.Auth.auth()
    private let db = Firestore.firestore()
    private var moniteringRegistration: ListenerRegistration? = nil
    
    init() {
        moniteringLogged()
    }
    deinit {
        moniteringRegistration?.remove()
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
    
}
