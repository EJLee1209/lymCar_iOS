//
//  LoginView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

enum LoginField {
    case email, password
}

struct LoginView: View {
    @Binding var loginStatus: Bool
    // @State 속성을 포함한 데이터 저장을 위한 @AppStorage
    @AppStorage("email") private var email = ""
    @AppStorage("password") private var password = ""
    
    @State var isLoginSuccess: Bool = false
    @State var showAlert: Bool = false
    @State var alertMsg: String = ""
    
    @ObservedObject var keyboard: KeyboardObserver = KeyboardObserver()
    @StateObject var viewModel = WelcomeViewModel()
    // 키보드 입력 FocusState
    @FocusState private var focusField: LoginField?
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.authResult == .loading)) {
            ZStack(alignment: .topLeading) {
                Image("welcomeBg")
                    .resizable()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("로그인")
                        .foregroundColor(Color("white"))
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .padding(.top, keyboard.isShowing ? 100 : 157)
                        .padding(.leading, 21)
                    
                    ZStack(alignment: .bottom) {
                        Color(.white)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                
                                Text("로그인")
                                    .font(.system(size: 24))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color("black"))
                                    .padding(.top, 27)
                                    .padding(.leading, 21)
                                
                                RoundedTextField(
                                    text: $email,
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
                                    text: $password,
                                    isValid: .constant(true),
                                    placeHolder: "비밀번호",
                                    type: .password
                                )
                                    .padding([.horizontal, .top], 10)
                                    .focused($focusField, equals: .password)
                                    .submitLabel(.done)
                                    
                                Button {
                                    
                                } label: {
                                    Text("비밀번호를 잊었어요")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color("main_blue"))
                                        .frame(alignment: .center)
                                        .padding([.top,.horizontal], 17)
                                }.frame(maxWidth: .infinity)
                            }
                        }
                        NavigationLink(isActive: $isLoginSuccess) {
                            MainView(loginStatus: $loginStatus).navigationBarBackButtonHidden()
                        } label: {}
                        
                        RoundedButton(label: "로그인", buttonColor: "main_blue", labelColor: "white")
                            .padding(.horizontal, 20)
                            .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                            .onTapGesture {
                                viewModel.checkLogged(email: email)
                            }
                            .alert("로그인 실패", isPresented: $showAlert) {
                                HStack {
                                    if alertMsg == Constants.LOGIN_ALREADY_LOGGED{
                                        Button("확인", role: .destructive) {
                                            viewModel.login(email: email, password: password)
                                        }
                                    }
                                    Button("취소", role: .cancel) {}
                                }
                                
                            } message: {
                                Text(alertMsg)
                            }
                        
                    }.cornerRadius(40)
                        .padding(.top, 18)
                }
            }
            .ignoresSafeArea(.keyboard)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                self.keyboard.addObserver()
                self.focusField = .email
            }
            .onDisappear {
                self.keyboard.removeObserver()
            }
            .onChange(of: viewModel.authResult) { newValue in
                switch newValue {
                case .failure(let msg):
                    // 이미 로그인한 기기가 있거나 로그인 실패
                    alertMsg = msg
                    showAlert = true
                case .success(let msg):
                    if msg == Constants.LOGIN_POSSIBLE {
                        // 로그인 가능
                        viewModel.login(email: email, password: password)
                    }
                    if msg == Constants.LOGIN_SUCCESS {
                        // 로그인 성공
                        isLoginSuccess = true
                    }
                default:
                    break
                }
            }
        }
        
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(loginStatus: .constant(true))
    }
}
