//
//  WelcomeViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation
import Alamofire
import Firebase

class WelcomeViewModel: ObservableObject {
    private let baseUrl = Bundle.main.baseUrl
    private let db = Firestore.firestore()
    private let auth = Firebase.Auth.auth()
    @Published var verifyState: VerifyState = .idle
    @Published var authResult: AuthResult = .idle
    
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
    
    func createUser(email: String, password: String, newUser: User) {
        authResult = .loading
        var copyUser = newUser
        
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error : \(error.localizedDescription)")
                self.authResult = .failure(error.localizedDescription)
                return
            }

            guard let user = result?.user else {
                self.authResult = .failure(Constants.GET_USER_INFO_FAILED)
                return
            }

            copyUser.uid = user.uid

            self.db.collection("User").document(user.uid)
                .setData(copyUser.dictionary)

            self.db.collection("FcmTokens").document(user.uid)
                .setData(TokenInfo().dictionary)
            
            self.authResult = .success("회원가입이 완료되었습니다")
        }
    }
    
    func checkLogged(email: String) {
        self.authResult = .loading
        let splitEmail = email.split(separator: "@")
        
        print(String(splitEmail[0]))
        db.collection("SignedIn").whereField("email", isEqualTo: String(splitEmail[0]))
            .getDocuments { snapshot, error in
                if let error = error {
                    self.authResult = .failure(Constants.GET_USER_INFO_FAILED)
                    print(error.localizedDescription)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.authResult = .success(Constants.LOGIN_POSSIBLE)
                    return
                }
                
                let deviceId = document.get("deviceId") as! String
                
                if deviceId == Utils.getDeviceUUID() {
                    self.authResult = .success(Constants.LOGIN_POSSIBLE)
                } else {
                    self.authResult = .failure(Constants.LOGIN_ALREADY_LOGGED)
                }
            }
    }
    
    func login(email: String, password: String) {
        authResult = .loading
        let splitEmail = email.split(separator: "@")
        
        auth.signIn(withEmail: email, password: password) { result, error in
            if let safeError = error {
                print("Error : \(safeError.localizedDescription)")
                self.authResult = .failure(Constants.LOGIN_INVALID_INFO)
            }
            
            guard let user = result?.user else {
                self.authResult = .failure(Constants.GET_USER_INFO_FAILED)
                return
            }
            
            self.db.collection("SignedIn").document(user.uid)
                .setData(
                    SignedIn(
                        uid: user.uid,
                        email: String(splitEmail[0]),
                        deviceId: Utils.getDeviceUUID()
                    ).dictionary
                )
            
            self.authResult = .success(Constants.LOGIN_SUCCESS)
        }
    }
    
}
