//
//  AppNetworking.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/27.
//

import Foundation
import Alamofire

final class AppNetworking {
  static let shared = AppNetworking()
  
  private init() { }
  
  private let session: Session = {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 10
    configuration.timeoutIntervalForResource = 10
    return Session(configuration: configuration)
  }()
  
  func requestJSON<T: Decodable>
    (
        _ url: String,
        type: T.Type,
        method: HTTPMethod,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil
    ) async throws -> T {
        return try await session.request(
            url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "",
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
        .serializingDecodable()
        .value
  }
}
