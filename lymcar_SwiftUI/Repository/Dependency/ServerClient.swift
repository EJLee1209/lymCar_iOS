//
//  ServerClient.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/08.
//

import Foundation
import ComposableArchitecture

struct ServerClient {
    var sendVerifyCode: @Sendable(_ email: String) async throws -> VerifyInfo
    var requestVerifyCode: @Sendable(_ email: String, _ code: String) async throws -> VerifyInfo
}

extension DependencyValues {
    var serverClient: ServerClient {
        get { self[ServerClient.self] }
        set { self[ServerClient.self] = newValue }
    }
}

enum APIError: Error {
    case invalidURL
}

//MARK: - Live Api implementation
extension ServerClient: DependencyKey {
    static let liveValue = ServerClient(
        sendVerifyCode: { email in
            if (!email.contains("@hallym.ac.kr")) {
                // 한림 웹메일이 아님
                throw APIError.invalidURL
            }
            let requestUrlString = "\(Bundle.main.baseUrl)api/email/create?email=\(email)"
            return try await AppNetworking.shared.requestJSON(requestUrlString, type: VerifyInfo.self, method: .post)
        },
        requestVerifyCode: { email, code in
            let requestUrlString = "\(Bundle.main.baseUrl)api/email/verify?email=\(email)&code=\(code)"
            return try await AppNetworking.shared.requestJSON(requestUrlString, type: VerifyInfo.self, method: .post)
        }
    )
    
}
