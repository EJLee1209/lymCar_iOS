//
//  EmailVerifyView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import ComposableArchitecture


//MARK: - EmailVerifyFeature
struct EmailVerifyFeature: ReducerProtocol {
    struct State: Equatable {
        var email = ""
        var alert : AlertState<Action>?
        var isSendOk = false
        var isLoading = false
        
        let guideText = "학교 웹메일을 통해 재학생 인증을 해주세요"
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
        case dismissAlert // alert 닫음
        case onDisappear
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
    }
}

//MARK: - EmailVerifyView
struct EmailVerifyView: View {
    @Binding var comeBackToRootView: Bool
    
    @FocusState private var focusField: Int?
    
    @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
    
    let store: StoreOf<EmailVerifyFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            LoadingView(isShowing: .constant(viewStore.isLoading)) {
                ZStack(alignment: .center){
                    Image("welcomeBg").resizable()
                    VStack(alignment: .leading, spacing: 0) {
                        Text("회원가입")
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                            .padding(.top, keyboard.isShowing ? 100 : 157)
                            .padding(.leading, 21)
                        
                        ZStack(alignment: .bottom) {
                            Color(.white)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("재학생 인증")
                                        .font(.system(size: 24))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("black"))
                                        .padding(.top, 27)
                                        .padding(.leading, 21)
                                    Text(viewStore.guideText)
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("black"))
                                        .padding(.leading, 21)
                                        .padding(.top, 5)
                                    
                                    RoundedTextField(
                                        text: Binding(
                                            get: { viewStore.email },
                                            set: { viewStore.send(.changedEmail($0)) }
                                        ),
                                        isValid: .constant(true),
                                        placeHolder: "학교 웹메일",
                                        type: .normal
                                    )
                                        .padding(.horizontal, 10)
                                        .padding(.top, 34)
                                        .focused($focusField, equals: 0)
                                }
                            }
                            NavigationLink(isActive: Binding(
                                get: { viewStore.isSendOk },
                                set: {_ in})
                            ) {
                                VerifyCodeView(email: viewStore.email, comeBackToRootView: $comeBackToRootView)
                            } label: {}
                            
                            RoundedButton(label: "인증하기", buttonColor: "main_blue", labelColor: "white")
                                .padding(.horizontal, 20)
                                .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                                .onTapGesture {
                                    viewStore.send(.requestSendVerifyCode(viewStore.email))
                                }
                                .alert(
                                    self.store.scope(state: \.alert),
                                    dismiss: .dismissAlert
                                )
                            
                        }
                        .roundedCorner(40, corners: [.topLeft, .topRight])
                        .padding(.top, 18)
                    }
                }.edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea(.keyboard)
                    .onAppear {
                        self.keyboard.addObserver()
                        focusField = 0
                        viewStore.send(.onAppear)
                    }
                    .onDisappear {
                        self.keyboard.removeObserver()
                    }
            }
        }
    }
}

struct EmailVerifyView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerifyView(
            comeBackToRootView: .constant(false),
            store: Store(initialState: EmailVerifyFeature.State(), reducer: EmailVerifyFeature())
        )
    }
}
