//
//  User.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/17.
//

import Foundation

struct User {
    var uid: String
    var email: String
    var name: String
    var gender: String
    
    var dictionary: [String: Any] {
        return [
            "uid" : uid,
            "email" : email,
            "name" : name,
            "gender" : gender
        ]
    }
}
