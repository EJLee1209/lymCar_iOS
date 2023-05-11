//
//  User.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/17.
//

import Foundation

struct User: Codable {
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
    
    var genderKor: String {
        switch self.gender {
        case Constants.GENDER_OPTION_MALE:
            return "남성"
        case Constants.GENDER_OPTION_FEMALE:
            return "여성"
        default:
            return "선택 안함"
        }
    }
}

extension [String: Any] {
    var dictToUser : User {
        return User(
            uid: self["uid"] as! String,
            email: self["email"] as! String,
            name: self["name"] as! String,
            gender: self["gender"] as! String
        )
    }
}
