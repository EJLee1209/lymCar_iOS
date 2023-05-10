//
//  EmailVerifyView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import ComposableArchitecture

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
                                set: { _ in})
                            ) {
                                VerifyCodeView(
                                    email: viewStore.email,
                                    comeBackToRootView: $comeBackToRootView,
                                    store: self.store.scope(
                                        state: \.verifyCodeState,
                                        action: EmailVerifyFeature.Action.verifyCodeAction
                                    )
                                )
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
