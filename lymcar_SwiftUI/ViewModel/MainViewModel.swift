//
//  MainViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation
import Firebase
import Alamofire

class MainViewModel: ObservableObject {
    @Published var detectAnonymous: Bool = false
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
        print(requestUrl)
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
                    print(searchResult.documents)
                case .failure(let error):
                    print(error.localizedDescription)
                
                }
            }
    }
    
}
