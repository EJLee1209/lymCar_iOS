//
//  VerifyViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/17.
//

import Foundation
import Alamofire
import Combine

class VerifyViewModel: ObservableObject {
    private let baseUrl = Bundle.main.baseUrl
    @Published var verifyState: VerifyState = .idle
    
    func sendVerifyCode(_ email: String) {
        verifyState = .loading
        let url = "\(baseUrl)api/email/create?email=\(email)"
        print("post request url : \(url)\n email : \(email)")
        
        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseDecodable(of: VerifyInfo.self) { response in
                switch response.result {
                case .success(let verifyInfo):
                    self.verifyState = .success(verifyInfo)
                case .failure(let error):
                    if error.isSessionTaskError {
                        // 네트워크 에러
                        self.verifyState = .failure("네트워크 연결을 확인해주세요")
                    }
                    else if error.isInvalidURLError {
                        // 입력 에러
                        self.verifyState = .failure("유효한 이메일을 입력해주세요")
                    }
                    else {
                        // 알 수 없는 오류
                        self.verifyState = .failure("서버 점검 중 입니다.\n이용에 불편을 드려 죄송합니다.")
                    }
                }
            }
        
    }
    
    func requestVerifyCode(_ email: String, _ code: String) {
        verifyState = .loading
        let url = "\(baseUrl)api/email/verify?email=\(email)&code=\(code)"
        
        AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default)
            .responseDecodable(of: VerifyInfo.self) { response in
                switch response.result {
                case .success(let verifyInfo):
                    self.verifyState = .success(verifyInfo)
                case .failure(let error):
                    if error.isSessionTaskError {
                        // 네트워크 에러
                        self.verifyState = .failure("네트워크 연결을 확인해주세요")
                    }
                    else if error.isInvalidURLError {
                        // 입력 에러
                        self.verifyState = .failure("인증코드를 다시 확인해주세요")
                    }
                    else {
                        // 알 수 없는 오류
                        self.verifyState = .failure("서버 점검 중 입니다.\n이용에 불편을 드려 죄송합니다.")
                    }
                    
                }
            }
    }
    
}
