//
//  TokenInfo.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/17.
//

import Foundation

struct TokenInfo {
    var token: String = ""
    var roomId: String = ""
    var platform: String = "ios"
    
    var dictionary: [String: Any] {
        return [
            "token" : token,
            "roomId" : roomId,
            "platform" : platform
        ]
    }
}
