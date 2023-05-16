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
            guard let url = URL(string: "\(Bundle.main.baseUrl)api/email/create?email=\(email)") else {
                throw APIError.invalidURL
            }
            return try await request(url: url)
        },
        requestVerifyCode: { email, code in
            guard let url = URL(string: "\(Bundle.main.baseUrl)api/email/verify?email=\(email)&code=\(code)") else {
                throw APIError.invalidURL
            }
            return try await request(url: url)
        }
    )
    
    static func request(url: URL) async throws -> VerifyInfo {
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(VerifyInfo.self, from: data)
    }
    
    
}
