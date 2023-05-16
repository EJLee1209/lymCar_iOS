//
//  LoginView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import ComposableArchitecture

enum LoginField {
    case email, password
}

struct LoginView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    // @State 속성을 포함한 데이터 저장을 위한 @AppStorage
    @AppStorage("email") private var email = ""
    @AppStorage("password") private var password = ""
    @AppStorage("didLogin") private var didLogin = false
    
    @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
    // 키보드 입력 FocusState
    @FocusState private var focusField: LoginField?
    
    let store: StoreOf<LoginFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            LoadingView(isShowing: .constant(viewStore.isLoading)) {
                ZStack(alignment: .topLeading) {
                    Image("welcomeBg")
                        .resizable()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("로그인")
                            .foregroundColor(Color("white"))
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                            .padding(.leading, 21)
                            .padding(.top, self.keyboard.isShowing ? 100 : 157)
                        
                        ZStack(alignment: .bottom) {
                            Color(.white)
                            VStack(alignment: .leading, spacing: 0) {
                                Text("로그인")
                                    .font(.system(size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 27)
                                    .padding(.leading, 21)
                                
                                RoundedTextField(
                                    text: Binding(
                                        get: { viewStore.email },
                                        set: {
                                            viewStore.send(.emailChanged($0))
                                            email = $0
                                        }
                                    ),
                                    isValid: .constant(true),
                                    placeHolder: "한림 웹메일",
                                    type: .normal,
                                    submitLabel: .next
                                )
                                    .padding(.horizontal, 10)
                                    .padding(.top, 17)
                                    .submitLabel(.next)
                                    .focused($focusField, equals: .email)
                                    .onSubmit {
                                        focusField = .password
                                    }
                                RoundedTextField(
                                    text: Binding(
                                        get: { viewStore.password },
                                        set: {
                                            viewStore.send(.passwordChanged($0))
                                            password = $0
                                        }
                                    ),
                                    isValid: .constant(true),
                                    placeHolder: "비밀번호",
                                    type: .password
                                )
                                    .padding([.horizontal, .top], 10)
                                    .focused($focusField, equals: .password)
                                    .submitLabel(.done)
                                    
                                Button {
                                    // 비밀번호 찾기
                                } label: {
                                    Text("비밀번호를 잊었어요")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("main_blue"))
                                        .frame(alignment: .center)
                                        .padding([.top,.horizontal], 17)
                                }.frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                            
                            RoundedButton(label: "로그인", buttonColor: "main_blue", labelColor: "white")
                                .onTapGesture {
                                    viewStore.send(.requestCheckLogged)
                                }
                                .alert(
                                    self.store.scope(state: \.alert),
                                    dismiss: .dismissAlert
                                )
                                .padding(.horizontal, 20)
                                .padding(.bottom, self.keyboard.isShowing ? keyboard.height : 47)
                        }
                        .roundedCorner(40, corners: [.topLeft, .topRight])
                        .padding(.top, 18)
                    }
                    // 로그인 성공시 메인화면으로 이동하기 위한 NavigationLink
                    NavigationLink(isActive: Binding(
                        get: { viewStore.isLoginSuccess },
                        set: { _ in }
                    )) {
                        MainView().navigationBarBackButtonHidden()
                            .environmentObject(appDelegate)
                    } label: {}
                }
                .ignoresSafeArea(.keyboard)
                .edgesIgnoringSafeArea(.all)
                .animation(.spring(), value: self.keyboard.isShowing)
                .onAppear {
                    self.keyboard.addObserver()
                    self.focusField = .email
                    viewStore.send(.onAppear(email, password))
                }
                .onDisappear {
                    self.keyboard.removeObserver()
                }
                .onChange(of: viewStore.isLoginSuccess) { newValue in
                    didLogin = newValue
                }
            }
        }
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(
            store: Store(initialState: LoginFeature.State(), reducer: LoginFeature())
        )
        .environmentObject(AppDelegate())
    }
}
