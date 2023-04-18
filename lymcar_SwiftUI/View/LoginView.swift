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
    @State var email: String = ""
    @State var password: String = ""
    @State var isLoginSuccess: Bool = false
    @State var showAlert: Bool = false
    
    @ObservedObject var keyboard: KeyboardObserver = KeyboardObserver()
    @StateObject var viewModel = AuthViewModel()
    // 키보드 입력 FocusState
    @FocusState private var focusField: LoginField?
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.authResult == .loading)) {
            ZStack(alignment: .topLeading) {
                Image("welcomeBg")
                    .resizable()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("로그인")
                        .foregroundColor(.white)
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
                            Text("로그인 성공")
                        } label: {}
                        
                        RoundedButton(label: "로그인", buttonColor: "main_blue", labelColor: "white")
                            .padding(.horizontal, 20)
                            .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                            .onTapGesture {
                                viewModel.login(email: email, password: password)
                            }
                            .alert("로그인 실패", isPresented: $showAlert) {
                                Button("확인", role: .cancel) {}
                            } message: {
                                Text("웹메일 또는 비밀번호를 확인해주세요")
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
                case .failure:
                    showAlert = true
                case .success:
                    isLoginSuccess = true
                default:
                    break
                }
            }
        }
        
    }
    
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
