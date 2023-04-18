//
//  MainViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation
import Firebase

class MainViewModel: ObservableObject {
    @Published var detectAnonymous: Bool = false
    
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
        moniteringRegistration = db.collection("SignedIn").document(auth.currentUser!.uid)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print(error)
                    return
                }
                
                guard let snapshot = snapshot else {
                    return
                }
                let deviceId = snapshot.get("deviceId") as! String
                
                if deviceId != Utils.getDeviceUUID() {
                    self.detectAnonymous = true
                }
                
            }
    }
}
