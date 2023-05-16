//
//  EmailVerifyFeature.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/10.
//

import Foundation
import ComposableArchitecture


//MARK: - EmailVerifyFeature
struct EmailVerifyFeature: ReducerProtocol {
    struct State: Equatable {
        var email = ""
        var alert : AlertState<Action>?
        var isSendOk = false
        var isLoading = false
        var isCompleteRegister = false
        
        let guideText = "학교 웹메일을 통해 재학생 인증을 해주세요"
        var verifyCodeState = VerifyCodeFeature.State() // 다음 화면의 state
    }
    
    enum Action: Equatable {
        static func == (lhs: EmailVerifyFeature.Action, rhs: EmailVerifyFeature.Action) -> Bool {
            switch (lhs, rhs) {
            case (Action.changedEmail, .changedEmail),
                (Action.requestSendVerifyCode, .requestSendVerifyCode),
                (Action.responseSendVerifyCode, .responseSendVerifyCode):
                return true
            default:
                return false
            }
        }
        
        case changedEmail(String) // Email 입력
        case requestSendVerifyCode(_ email: String) // 인증 코드 전송 요청
        case responseSendVerifyCode(TaskResult<VerifyInfo>) // 인증 코드 전송 요청에 대한 response
        case verifyCodeAction(VerifyCodeFeature.Action) // 다음화면의 action
        
        case dismissAlert // alert 닫음
        case onAppear
    }
    
    @Dependency(\.serverClient) var serverClient
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
                // email 입력
            case let .changedEmail(newValue):
                state.email = newValue
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
                
            case .verifyCodeAction(VerifyCodeFeature.Action.registerFeatureAction(.onDisappear)):
                state = .init()
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
        Scope(state: \.verifyCodeState, action: /Action.verifyCodeAction) {
            VerifyCodeFeature()
        }
    }
}
