//
//  VerifyInfo.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/16.
//

import Foundation
import Alamofire

enum VerifyState {
    case idle
    case loading
    case success(VerifyInfo)
    case failure(String)
}
extension VerifyState: Equatable {
    static func == (lhs: VerifyState, rhs: VerifyState) -> Bool {
        switch (lhs, rhs) {
        case(.idle, .idle):
            return true
        case(.loading, .loading):
            return true
        case(.success(let lhsValue), .success(let rhsValue)):
            return lhsValue.message == rhsValue.message
        case(.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}


struct VerifyInfo: Codable {
    var status: String
    var message: String
    var data: VerifyData
    
    private enum CodingKeys: String, CodingKey {
        case status = "status"
        case message = "message"
        case data = "data"
    }
}

struct VerifyData: Codable {
    var verified: Bool
    
    private enum CodingKeys: String, CodingKey {
        case verified = "verified"
    }
}
