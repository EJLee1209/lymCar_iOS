//
//  SignedIn.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation

struct SignedIn {
    var uid: String = ""
    var email: String = ""
    var deviceId: String = ""
    
    var dictionary: [String: Any] {
        return [
            "uid" : uid,
            "email" : email,
            "deviceId" : deviceId
        ]
    }
}
