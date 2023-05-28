//
//  LoginFeature.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/10.
//

import Foundation
import ComposableArchitecture
import Firebase

struct LoginFeature: ReducerProtocol {
    struct State: Equatable {
        var email = ""
        var password = ""
        var isLoginSuccess: Bool = false
        var isLoading = false
        var alert: AlertState<Action>?
    }
    
    @Dependency(\.authClient) var authClient
    enum Action: Equatable {
        static func == (lhs: LoginFeature.Action, rhs: LoginFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (Action.emailChanged, .emailChanged),
                (Action.passwordChanged, .passwordChanged),
                (Action.requestCheckLogged, .requestCheckLogged),
                (Action.responseCheckLogged, .responseCheckLogged),
                (Action.requestLogin, .requestLogin),
                (Action.responseLogin, .responseLogin):
                return true
            default:
                return false
            }
        }
        
        case emailChanged(String)
        case passwordChanged(String)
        case changedLoginStatus(Bool)
        case forgotPasswordClicked
        
        case requestCheckLogged // 로그인 여부 확인 요청
        case responseCheckLogged(TaskResult<Void>) // 로그인 여부 확인에 대한 response
        case requestLogin // 로그인 요청
        case requestPasswordReset // 비밀번호 초기화 요청
        
        case responseLogin(TaskResult<Void>) // 로그인 요청에 대한 response
        case responsePasswordReset(TaskResult<Void>) // 비밀번호 초기화 요청에 대한 response
        
        case dismissAlert
        case onAppear(String, String)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .emailChanged(newValue):
                state.email = newValue
                return .none
                
            case let .passwordChanged(newValue):
                state.password = newValue
                return .none
                
            case let .changedLoginStatus(newValue):
                state.isLoginSuccess = newValue
                return .none
                
            case .requestCheckLogged:
                state.isLoading.toggle()
                return EffectTask.run { [email = state.email] send in
                    let result = await TaskResult { try await
                        authClient.checkLogged(email)
                    }
                    await send(.responseCheckLogged(result))
                }
                
            case .responseCheckLogged(.success): // 로그인 가능 상태
                return EffectTask.run { [email = state.email, password = state.password] send in
                    let result = await TaskResult { try await
                        authClient.login(email, password)
                    }
                    await send(.responseLogin(result))
                }
                
            case .responseCheckLogged(.failure): // 다른기기로 로그인한 기록이 있음
                state.isLoading.toggle()
                state.alert = AlertState(title: {
                    TextState("로그인 실패")
                }, actions: {
                    ButtonState(action: .requestLogin) {
                        TextState("로그인")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                }, message: {
                    TextState(Constants.LOGIN_ALREADY_LOGGED)
                })
                return .none
                
            case .requestLogin:
                state.isLoading.toggle()
                return EffectTask.run { [email = state.email, password = state.password] send in
                    let result = await TaskResult { try await
                        authClient.login(email, password)
                    }
                    await send(.responseLogin(result))
                }
                
            case .responseLogin(.success):
                state.isLoading.toggle()
                state.isLoginSuccess = true
                return .none
                
            case let .responseLogin(.failure(error)):
                state.isLoading.toggle()
                state.isLoginSuccess = false
                print("login error : \(error)")
                var errorMsg : String
                switch error {
                case AuthErrorCode.wrongPassword:
                    errorMsg = "비밀번호가 틀렸습니다"
                case AuthErrorCode.invalidEmail:
                    errorMsg = "이메일이 틀렸습니다"
                case AuthErrorCode.networkError:
                    errorMsg = Constants.NETWORK_ERROR
                case AuthErrorCode.userNotFound:
                    errorMsg = "회원가입 후 이용해주세요"
                default:
                    errorMsg = error.localizedDescription
                }
                state.alert = AlertState(title: {
                    TextState("로그인 실패")
                }, actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                }, message: {
                    TextState(errorMsg)
                })
                return .none
                
            case .forgotPasswordClicked:
                state.alert = AlertState(title: {
                    TextState("비밀번호 재설정")
                }, actions: {
                    ButtonState(action: .requestPasswordReset) {
                        TextState("확인")
                    }
                    ButtonState(role: .cancel) {
                        TextState("취소")
                    }
                }, message: {
                    TextState("비밀번호를 잊으셨나요? 비밀번호 재설정을 위한 안내를 한림 웹메일로 보내드리겠습니다.")
                })
                return .none
                
            case .requestPasswordReset:
                state.isLoading = true
                return EffectTask.run { [email = state.email] send in
                    let result = await TaskResult { try await
                        authClient.passwordReset(email)
                    }
                    await send(.responsePasswordReset(result))
                }
                
            case .responsePasswordReset(.success):
                state.isLoading = false
                state.alert = AlertState(title: {
                    TextState("비밀번호 재설정")
                }, actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                }, message: {
                    TextState("비밀번호 재설정을 위한 안내를 한림 웹메일로 전송했습니다")
                })
                return .none
                
            case let .responsePasswordReset(.failure(error)):
                state.isLoading = false
                var errorMsg : String
                switch error {
                case AuthErrorCode.invalidEmail:
                    errorMsg = "이메일이 틀렸습니다"
                case AuthErrorCode.networkError:
                    errorMsg = Constants.NETWORK_ERROR
                case AuthErrorCode.userNotFound:
                    errorMsg = "회원정보가 존재하지 않습니다"
                case AuthErrorCode.missingEmail:
                    errorMsg = "이메일을 입력해주세요"
                default:
                    errorMsg = error.localizedDescription
                }
                state.alert = AlertState(title: {
                    TextState("비밀번호 재설정")
                }, actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                }, message: {
                    TextState(errorMsg)
                })
                return .none
            case .dismissAlert:
                state.alert = nil
                return .none
                
            case let .onAppear(email, password):
                state = .init()
                state.email = email
                state.password = password
                return .none
            default:
                return .none
            }
        }
    }
}
