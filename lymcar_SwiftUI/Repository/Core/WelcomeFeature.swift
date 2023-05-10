//
//  WelcomeFeture.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/08.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct WelcomeFeature: ReducerProtocol {
    struct State: Equatable {
        var email=""
        var password=""
        var registrationInProgress = false
        var autoLogin = false
        var isLoading = true
        var alert: AlertState<Action>?
        
        // 다른 view의 state
        var EmailVerifyState = EmailVerifyFeature.State()
        var LoginViewState = LoginFeature.State()
    }
    
    enum Action: Equatable {
        static func == (lhs: WelcomeFeature.Action, rhs: WelcomeFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (Action.responseCheckLogged, Action.responseCheckLogged),
                (Action.requestCheckLogged, Action.requestCheckLogged),
                (Action.requestLogin, Action.requestLogin),
                (Action.responseLogin, Action.responseLogin),
                (Action.dismissAlert, Action.dismissAlert),
                (Action.onAppear, Action.onAppear):
                return true
            default:
                return false
            }
        }
        
        // 로그인 여부 확인 요청
        case requestCheckLogged(_ email: String)
        // 로그인 여부 확인 요청에 대한 응답
        case responseCheckLogged(TaskResult<Void>)
        // 로그인 요청
        case requestLogin
        // 로그인 요청에 대한 응답
        case responseLogin(TaskResult<Void>)
        
        case getSavedEmail(_ email: String)
        case getSavedPassword(_ password: String)
        case changedRegistrationInProgress(_ newValue: Bool)
        case changedIsLoading
        
        // alert dismiss
        case dismissAlert
        case onAppear
        
        // 다른 view의 action
        case EmailVerifyAction(EmailVerifyFeature.Action)
        case LoginViewAction(LoginFeature.Action)
    }
    
    @Dependency(\.authClient) var authClient
    var body: some ReducerProtocol<State, Action> {
        Reduce{ state, action in
            switch action {
                // 로그인 여부 확인 요청
            case let .requestCheckLogged(email):
                return EffectTask.run { send in
                    let result = await TaskResult { try await
                        authClient.checkLogged(email)
                    }
                    await send(.responseCheckLogged(result))
                }
                // 로그인 여부 확인 요청에 대한 response
            case .responseCheckLogged(.success):
                // 로그인 가능 -> 로그인 요청
                return EffectTask.run { [email = state.email, password = state.password] send in
                    let result = await TaskResult { try await
                        authClient.login(email, password)
                    }
                    await send(.responseLogin(result))
                }
            case let .responseCheckLogged(.failure(error)):
                switch error {
                case AuthError.alreadyLogged:
                    // 이미 로그인한 기기가 있음을 알리는 alert를 띄워줌
                    state.alert = AlertState(title: {
                        TextState("시스템 메세지")
                    },actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    },message: {
                        TextState(Constants.AUTO_LOGOUT)
                    })
                    state.isLoading.toggle()
                    return .none
                default:
                    // 오류 발생
                    state.alert = AlertState(title: {
                        TextState("시스템 메세지")
                    },actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    },message: {
                        TextState(Constants.GET_USER_INFO_FAILED)
                    })
                    return .none
                }
                // 로그인 요청
            case .requestLogin:
                return EffectTask.run { [email = state.email, password = state.password] send in
                    let result = await TaskResult { try await
                        authClient.login(email, password)
                    }
                    await send(.responseLogin(result))
                }
                
                // 로그인 요청에 대한 response
            case .responseLogin(.success):
                state.autoLogin = true
                state.isLoading.toggle()
                return .none
            case .responseLogin(.failure(_)):
                // 로그인 실패
                state.alert = AlertState(title: {
                    TextState("로그인에 실패했습니다")
                },actions: {
                    ButtonState(role: .cancel) {
                        TextState("확인")
                    }
                })
                state.isLoading.toggle()
                return .none
                
            case let .getSavedEmail(email):
                state.email = email
                return .none
            case let .getSavedPassword(password):
                state.password = password
                return .none
            case let .changedRegistrationInProgress(newValue):
                state.registrationInProgress = newValue
                return .none
            case .changedIsLoading:
                state.isLoading.toggle()
                return .none
                
            case .dismissAlert:
                state.alert = nil
                return .none
            
            case .onAppear:
                state = .init()
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.EmailVerifyState, action: /Action.EmailVerifyAction) {
            EmailVerifyFeature()
        }
        Scope(state: \.LoginViewState, action: /Action.LoginViewAction) {
            LoginFeature()
        }
    }
}
