//
//  AuthResult.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation

enum AuthResult {
    case idle
    case loading
    case failure(String)
    case success(String)
}

extension AuthResult: Equatable {
    static func == (lhs: AuthResult, rhs: AuthResult) -> Bool {
        switch (lhs, rhs) {
        case(.idle, .idle):
            return true
        case(.loading, .loading):
            return true
        case(.success(let lhsValue), .success(let rhsValue)):
            return lhsValue == rhsValue
        case(.failure(let lhsError), .failure(let rhsError)):
            return lhsError == rhsError
        case(.loading, .idle):
            return false
        default:
            return false
        }
    }
}
