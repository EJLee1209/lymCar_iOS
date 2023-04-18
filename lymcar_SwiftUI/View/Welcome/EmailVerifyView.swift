//
//  EmailVerifyView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

struct EmailVerifyView: View {
    @Binding var comeBackToRootView: Bool
    
    @State var email: String = ""
    @State var guideText: String = "학교 웹메일을 통해 재학생 인증을 해주세요"
    @State var isAlertPresent: Bool = false
    @State var alertText: String = ""
    @State var sendState: Bool = false
    @FocusState private var focusField: Int?
    
    @ObservedObject var keyboard: KeyboardObserver = KeyboardObserver()
    @StateObject var viewModel = WelcomeViewModel()
    
    

    var body: some View {
        LoadingView(isShowing: .constant(viewModel.verifyState == .loading)) {
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
                                    .padding(.top, 27)
                                    .padding(.leading, 21)
                                Text(guideText)
                                    .font(.system(size: 15))
                                    .padding(.leading, 21)
                                    .padding(.top, 5)
                                
                                RoundedTextField(
                                    text: $email,
                                    isValid: .constant(true),
                                    placeHolder: "학교 웹메일",
                                    type: .normal
                                )
                                    .padding(.horizontal, 10)
                                    .padding(.top, 34)
                                    .focused($focusField, equals: 0)
                            }
                        }
                        NavigationLink(isActive: $sendState) {
                            VerifyCodeView(email: email, comeBackToRootView: $comeBackToRootView)
                        } label: {}
                        
                        RoundedButton(label: "인증하기", buttonColor: "main_blue", labelColor: "white")
                            .padding(.horizontal, 20)
                            .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                            .onTapGesture {
                                viewModel.sendVerifyCode(email)
                            }
                            .alert("인증 오류", isPresented: $isAlertPresent) {
                                Button("확인", role: .cancel) {}
                            } message: {
                                Text(alertText)
                            }
                        
                    }.cornerRadius(40)
                        .padding(.top, 18)
                }
            }.edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
                .onAppear {
                    self.keyboard.addObserver()
                    focusField = 0
                }
                .onDisappear {
                    self.keyboard.removeObserver()
                }
                .onChange(of: viewModel.verifyState) { newValue in
                    switch newValue {
                    case .failure(let msg) :
                        isAlertPresent = true
                        alertText = msg
                    case .success(_) :
                        sendState = true
                    default :
                        break
                    }
                }
        }
        
    }
}

struct ExecuteCode : View {
    init( _ codeToExec: () -> () ) {
        codeToExec()
    }
    
    var body: some View {
        return EmptyView()
    }
}


struct EmailVerifyView_Previews: PreviewProvider {
    static var previews: some View {
        EmailVerifyView(comeBackToRootView: .constant(false))
    }
}
