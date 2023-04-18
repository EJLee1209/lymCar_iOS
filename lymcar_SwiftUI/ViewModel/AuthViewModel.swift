//
//  RegisterViewModel.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/17.
//

import Foundation
import Alamofire
import Firebase

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
class AuthViewModel: ObservableObject {
    private let db = Firestore.firestore()
    private let auth = Firebase.Auth.auth()
    @Published var authResult: AuthResult = .idle
    
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
                self.authResult = .failure("사용자 정보를 가져오지 못했습니다")
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
    
    func login(email: String, password: String) {
        authResult = .loading
        auth.signIn(withEmail: email, password: password) { result, error in
            if let safeError = error {
                print("Error : \(safeError.localizedDescription)")
                self.authResult = .failure(safeError.localizedDescription)
            }
            
            guard let _ = result?.user else {
                self.authResult = .failure("사용자 정보를 가져오지 못했습니다")
                return
            }
            
            self.authResult = .success("회원가입이 완료되었습니다")
        }
        
    }
    
}
