//
//  RegisterFeature.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/10.
//

import Foundation
import ComposableArchitecture
import Firebase

struct RegisterFeature: ReducerProtocol {
    struct State: Equatable {
        // 단순 값 저장을 위한 State
        var gender : Gender = .none
        var name: String = ""
        var passwordConfirm: String = ""
        var password: String = ""
        var guideText: String = "비밀번호를 입력해주세요"
        
        // 다음 단계로 넘어가기 위한 State
        var isAgreePrivacyPolicy: Bool = false
        var passwordOk: Bool = false
        var passwordConfirmOk: Bool = false
        var nameOk: Bool = false
        var genderOk: Bool = false
        var nextCount: Int = 0
        
        var isSuccessJoin: Bool = false // 회원가입 성공 여부
        var focusField: RegisterField? // focusState
        var isLoading: Bool = false // 로딩중?
    
        var alert: AlertState<Action>? // alert state
    }
    
    enum Action: Equatable {
        static func == (lhs: RegisterFeature.Action, rhs: RegisterFeature.Action) -> Bool {
            switch (lhs,rhs) {
            case (Action.passwordChanged, .passwordChanged),
                (Action.passwordConfirmChanged, .passwordConfirmChanged),
                (Action.nameChanged, .nameChanged),
                (Action.genderChanged, .genderChanged),
                (Action.guidTextChanged, .guidTextChanged),
                (Action.isAgreePrivacyPolicyChanged, .isAgreePrivacyPolicyChanged),
                (Action.submitPassword, .submitPassword),
                (Action.submitPasswordConfirm, .submitPasswordConfirm),
                (Action.submitName, .submitName),
                (Action.requestRegister, .requestRegister),
                (Action.responseRegister, .responseRegister):
                return true
            default:
                return false
            }
        }
        
        case passwordChanged(String) // 비밀번호 입력
        case passwordConfirmChanged(String) // 비밀번호 확인 입력
        case nameChanged(String) // 이름 입력
        case genderChanged(Gender) // 성별 입력
        case guidTextChanged(String) // guide text 변경
        case isAgreePrivacyPolicyChanged // 약관동의 여부 변경
        
        // SubmitAction (키보드에서 다음 버튼 눌렀을 때)
        case submitPassword
        case submitPasswordConfirm
        case submitName
        
        // 회원가입 요청
        case requestRegister(_ email: String)
        case responseRegister(TaskResult<Void>)
        case toggleSuccessJoin
        
        case dismissAlert
        case onAppear
        case onDisappear
    }
    
    @Dependency(\.authClient) var authClient
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .passwordChanged(newValue):
            state.password = newValue
            return .none
        case let .passwordConfirmChanged(newValue):
            state.passwordConfirm = newValue
            return .none
        case let .nameChanged(newValue):
            state.name = newValue
            return .none
        case let .genderChanged(newValue):
            state.gender = newValue
            return .none
        case let .guidTextChanged(newValue):
            state.guideText = newValue
            return .none
        case .isAgreePrivacyPolicyChanged:
            state.isAgreePrivacyPolicy.toggle()
            if state.isAgreePrivacyPolicy{
                state.guideText = "안녕하세요 \(state.name)님,\n입력한 정보가 모두 맞나요?"
            } else {
                state.guideText = "개인정보처리방침에 동의해주세요"
            }
            return .none
        case .submitPassword:
            if state.password.validatePassword() {
                state.passwordOk = true
                state.focusField = .passwordConfirm
                state.guideText = "비밀번호를 확인해주세요"
            } else {
                state.passwordOk = false
                state.focusField = .password
                state.guideText = "비밀번호 조합 규칙을 모두 준수해주세요"
            }
            return .none
        case .submitPasswordConfirm:
            if state.password == state.passwordConfirm {
                state.passwordConfirmOk = true
                state.focusField = .name
                state.guideText = "이름(실명)을 입력해주세요"
            } else {
                state.passwordConfirmOk = false
                state.focusField = .passwordConfirm
                state.guideText = "비밀번호가 다릅니다."
            }
            return .none
        case .submitName:
            if !state.name.isEmpty {
                state.nameOk = true
                state.focusField = nil
                state.guideText = "성별을 선택해주세요"
            } else{
                state.nameOk = false
                state.focusField = .name
                state.guideText = "이름(실명)을 입력해주세요"
            }
            return .none
        case let .requestRegister(email):
            state.isLoading.toggle()
            var genderValue: String
            switch state.gender {
            case .none: genderValue = "none"
            case .female: genderValue = "female"
            case .male: genderValue = "male"
            }
            let user = User(
                uid: "",
                email: email,
                name: state.name,
                gender: genderValue
            )
            return EffectTask.run { [password = state.password] send in
                let result = await TaskResult { try await
                    authClient.createUser(email, password, user)
                }
                await send(.responseRegister(result))
            }
        case .responseRegister(.success):
            state.isLoading.toggle()
            state.alert = AlertState(title: {
                TextState("회원가입 성공")
            }, actions: {
                ButtonState(action: .toggleSuccessJoin) {
                    TextState("완료")
                }
            }, message: {
                TextState(Constants.SUCCESS_REGISTER)
            })
            return.none
            
        case let .responseRegister(.failure(error)):
            state.isLoading.toggle()
            print("register error : \(error)")
            var errorMsg: String
            switch error {
            case AuthErrorCode.emailAlreadyInUse:
                errorMsg = "이미 회원가입한 이메일 입니다."
                state.alert = AlertState(title: {
                    TextState("회원가입 실패")
                }, actions: {
                    ButtonState(action: .toggleSuccessJoin) {
                        TextState("확인")
                    }
                }, message: {
                    TextState(errorMsg)
                })
                return .none
            case AuthErrorCode.networkError:
                errorMsg = "네트워크 오류입니다\n네트워크 연결을 확인하고 다시 시도해주세요"
            default:
                errorMsg = "알 수 없는 오류입니다.\n잠시 후 다시 시도해주세요"
            }
            
            state.alert = AlertState(title: {
                TextState("회원가입 실패")
            }, actions: {
                ButtonState(role: .cancel) {
                    TextState("확인")
                }
            }, message: {
                TextState(errorMsg)
            })
            return .none
            
        case .toggleSuccessJoin:
            state.isSuccessJoin.toggle()
            return .none
            
        case .dismissAlert:
            state.alert = nil
            return .none
        case .onAppear:
            state = .init()
            state.focusField = .password
            return .none
        case .onDisappear:
            state = .init()
            return .none
        default:
            return .none
        }
    }
}
