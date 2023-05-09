//
//  VerifyCodeView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import ComposableArchitecture

//MARK: - VerifyCodeFeature
struct VerifyCodeFeature: ReducerProtocol {
    struct State: Equatable {
        var codes: String = ""
        var isValidCode: Bool = false
        var alert: AlertState<Action>?
        var isLoading = false
        var isSendOk = false
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
            default:
                return .none
            }
        }
    }
}

//MARK: - VerifyCodeView
struct VerifyCodeView: View {
    @FocusState var isKeyboardShowing: Bool
    @StateObject var codeTimer = CodeTimer()
    @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
    
    var email: String
    @Binding var comeBackToRootView: Bool
    var store: StoreOf<VerifyCodeFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            LoadingView(isShowing: .constant(viewStore.isLoading)) {
                ZStack(alignment: .topLeading){
                    Image("welcomeBg").resizable()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("회원가입")
                            .foregroundColor(Color("white"))
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
                                    Text("웹메일로 전송되었습니다!\n인증번호를 입력하세요")
                                        .font(.system(size: 15))
                                        .foregroundColor(Color("black"))
                                        .padding(.leading, 21)
                                        .padding(.top, 5)
                                    
                                    ZStack {
                                        HStack(spacing: 5) {
                                            ForEach(0..<8, id: \.self) { index in
                                                CodeBox(index)
                                            }
                                        }
                                        .padding(EdgeInsets(top: 28, leading: 21, bottom: 0, trailing: 21))
                                        .background {
                                            TextField(
                                                "",
                                                text: Binding(
                                                    get: { viewStore.codes },
                                                    set: {
                                                        viewStore.send(.changedCodes($0))
                                                    }
                                                ).limit(8)
                                            )
                                                .keyboardType(.numberPad)
                                                .textContentType(.oneTimeCode)
                                                .frame(width: 1, height: 1)
                                                .opacity(0.001)
                                                .blendMode(.screen)
                                                .focused($isKeyboardShowing)
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            isKeyboardShowing.toggle()
                                        }
                                    }
                                    if !codeTimer.timeOver{
                                        Text("\(codeTimer.time / 60):\(codeTimer.time % 60) 안에 코드를 인증하세요")
                                            .font(.system(size: 12))
                                            .foregroundColor(Color("black"))
                                            .frame(maxWidth: .infinity)
                                            .padding([.top], 13)
                                    }

                                    if codeTimer.timeOver {
                                        Button {
                                            // 인증 코드 재발송
                                            viewStore.send(.requestSendVerifyCode(email))
                                        } label: {
                                            Text("다시 보내기")
                                                .font(.system(size: 15))
                                                .foregroundColor(Color("main_blue"))
                                                .padding(.all, 15)
                                        }
                                        .padding(.top, 24)
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            NavigationLink(isActive: Binding(
                                get: { viewStore.isValidCode },
                                set: { _ in })
                            ) {
                                RegisterView(email: email, comeBackToRootView: $comeBackToRootView)
                            } label: {}
                            
                            RoundedButton(label: "인증하기", buttonColor: "main_blue", labelColor: "white")
                                .padding(.horizontal, 20)
                                .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                                .onTapGesture {
                                    // 인증 요청
                                    viewStore.send(.requestVerifyCode(email))
                                }
                                
                            
                        }
                        .roundedCorner(40, corners: [.topLeft, .topRight])
                        .padding(.top, 18)
                    }
                    
                }.edgesIgnoringSafeArea(.all)
                    .ignoresSafeArea(.keyboard)
                    .onAppear {
                        self.keyboard.addObserver()
                        viewStore.send(.onAppear)
                    }
                    .onDisappear {
                        self.keyboard.removeObserver()
                    }
                    .alert(
                        self.store.scope(state: \.alert),
                        dismiss: .dismissAlert
                    )
            }
        }
    }
    
    @ViewBuilder
    func CodeBox(_ index: Int) -> some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color("f5f5f5")
                if viewStore.codes.count > index {
                    let startIndex = viewStore.codes.startIndex
                    let charIndex = viewStore.codes.index(startIndex, offsetBy: index)
                    let charToString = String(viewStore.codes[charIndex])
                    Text(charToString)
                } else {
                    Text(" ")
                }
                
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                if viewStore.codes.count == index {
                    RoundedRectangle(cornerRadius: 10).stroke(lineWidth: 2).foregroundColor(Color("main_blue"))
                }
            }
        }
    }
}

struct VerifyCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyCodeView(
            email: "email", comeBackToRootView: .constant(false),
            store: Store(initialState: VerifyCodeFeature.State(), reducer: VerifyCodeFeature())
        )
    }
}
