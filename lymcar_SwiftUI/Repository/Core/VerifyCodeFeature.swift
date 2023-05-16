//
//  VerifyCodeFeature.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/10.
//

import Foundation
import ComposableArchitecture

//MARK: - VerifyCodeFeature
struct VerifyCodeFeature: ReducerProtocol {
    struct State: Equatable {
        var codes: String = ""
        var isValidCode: Bool = false
        var alert: AlertState<Action>?
        var isLoading = false
        var isSendOk = false
        
        var registerState = RegisterFeature.State()
    }
    
    enum Action: Equatable {
        static func == (lhs: VerifyCodeFeature.Action, rhs: VerifyCodeFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (Action.changedCodes, .changedCodes),
                (Action.requestVerifyCode, .requestVerifyCode),
                (Action.responseVerifyCode, .responseVerifyCode),
                (Action.onAppear, .onAppear),
                (Action.dismissAlert, .dismissAlert):
                return true
            default:
                return false
            }
        }
        
        case changedCodes(String) // 인증 코드 입력
        case requestVerifyCode(_ email: String) //인증 코드 확인 요청
        case responseVerifyCode(TaskResult<VerifyInfo>) // 인증 코드 확인 요청에 대한 response
        case requestSendVerifyCode(_ email: String) // 인증 코드 전송 요청
        case responseSendVerifyCode(TaskResult<VerifyInfo>) // 인증 코드 전송 요청에 대한 response
        case registerFeatureAction(RegisterFeature.Action)
        
        case onAppear
        case dismissAlert
    }
    
    @Dependency(\.serverClient) var serverClient
    var body : some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case let .changedCodes(newValue):
                state.codes = newValue
                return .none
            case let .requestVerifyCode(email):
                state.isLoading.toggle()
                return EffectTask.run { [codes = state.codes] send in
                    let result = await TaskResult { try await
                        serverClient.requestVerifyCode(email, codes)
                    }
                    await send(.responseVerifyCode(result))
                }
            case let .responseVerifyCode(.success(verifyInfo)):
                state.isLoading.toggle()
                switch verifyInfo.message {
                case Constants.SUCCESS_VERIFY_CODE:
                    // 인증 성공
                    state.isValidCode = true
                default:
                    // 인증 실패
                    state.alert = AlertState(title: {
                        TextState("학교 인증")
                    }, actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    }, message: {
                        TextState(verifyInfo.message)
                    })
                }
                
                return .none
            case let .responseVerifyCode(.failure(error)):
                state.isLoading.toggle()
                switch error {
                case APIError.invalidURL:
                    state.alert = AlertState(title: {
                        TextState("학교 인증 실패")
                    }, actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    }, message: {
                        TextState(Constants.INVALID_VERIFY_CODE)
                    })
                default:
                    state.alert = AlertState(title: {
                        TextState("학교 인증 실패")
                    }, actions: {
                        ButtonState(role: .cancel) {
                            TextState("확인")
                        }
                    }, message: {
                        TextState("알 수 없는 오류입니다.\n잠시 후 다시 시도해주세요")
                    })
                }
                return .none
                // 인증 코드 발송 요청
            case let .requestSendVerifyCode(email):
                state.isLoading.toggle()
                return EffectTask.run { send in
                    let result = await TaskResult { try await
                        serverClient.sendVerifyCode(email)
                    }
                    await send(.responseSendVerifyCode(result))
                }
                // 인증 코드 발송 요청에 대한 응답
            case .responseSendVerifyCode(.success):
                state.isLoading.toggle()
                state.isSendOk.toggle()
                return .none
            case let .responseSendVerifyCode(.failure(error)):
                state.isLoading.toggle()
                state.isSendOk=false
                switch error {
                case APIError.invalidURL:
                    state.alert = AlertState(title: {
                        TextState("인증코드 전송 실패")
                    }, actions: {
                        ButtonState(role:.cancel) {
                            TextState("확인")
                        }
                    }, message: {
                        TextState(Constants.INVALID_EMAIL)
                    })
                default:
                    state.alert = AlertState(title: {
                        TextState("인증코드 전송 실패")
                    }, actions: {
                        ButtonState(role:.cancel) {
                            TextState("확인")
                        }
                    }, message: {
                        TextState("알 수 없는 오류입니다.\n잠시 후 다시 시도해주세요")
                    })
                }
                return .none
            case .dismissAlert:
                state.alert = nil
                return .none
            case .onAppear:
                state = .init()
                return .none
            case .registerFeatureAction(RegisterFeature.Action.onDisappear):
                print("RegisterFeature.Action.onDisappear 호출 (VerifyCodeFeature)")
                state = .init()
                return .none
            default:
                return .none
            }
        }
        Scope(state: \.registerState, action: /Action.registerFeatureAction) {
            RegisterFeature()
        }
    }
}
