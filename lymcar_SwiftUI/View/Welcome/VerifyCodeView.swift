//
//  VerifyCodeView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import ComposableArchitecture

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
                                RegisterView(
                                    email: email,
                                    comeBackToRootView: $comeBackToRootView,
                                    store: self.store.scope(
                                        state: \.registerState,
                                        action: VerifyCodeFeature.Action.registerFeatureAction
                                    )
                                )
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
