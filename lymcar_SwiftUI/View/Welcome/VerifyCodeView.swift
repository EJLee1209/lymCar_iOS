//
//  VerifyCodeView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

struct VerifyCodeView: View {
    var email: String
    @Binding var comeBackToRootView: Bool
    
    @State var codes: String = ""
    @State var isValidCode: Bool = false
    @State var isAlertPresent: Bool = false
    @State var alertText: String = ""
    @StateObject var codeTimer = CodeTimer()
    @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
    @StateObject var viewModel = WelcomeViewModel()
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.verifyState == .loading)) {
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
                                    TextField("", text: $codes.limit(8))
                                        .font(Font.system(size: 50))
                                        .padding([.horizontal], 20)
                                        .padding([.top], 28)
                                        .blendMode(.screen)
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
                                        viewModel.sendVerifyCode(email)
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
                        NavigationLink(isActive: $isValidCode) {
                            RegisterView(email: email, comeBackToRootView: $comeBackToRootView)
                        } label: {}
                        
                        RoundedButton(label: "인증하기", buttonColor: "main_blue", labelColor: "white")
                            .padding(.horizontal, 20)
                            .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                            .onTapGesture {
                                print("email : \(email) code: \(codes)")
                                viewModel.requestVerifyCode(email, codes)
                            }
                            .alert("학교 인증", isPresented: $isAlertPresent) {
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
                }
                .onDisappear {
                    self.keyboard.removeObserver()
                }
                .onChange(of: viewModel.verifyState) { newValue in
                    switch newValue {
                    case .failure(let msg) :
                        isAlertPresent = true
                        alertText = msg
                    case .success(let response) :
                        switch response.message {
                        case Constants.SUCCESS_VERIFY_CODE:
                            isValidCode = true
                        default:
                            isAlertPresent = true
                            alertText = response.message
                        }
                    default :
                        break
                    }
                }
        }
        
    }
    
    @ViewBuilder
    func CodeBox(_ index: Int) -> some View {
        ZStack {
            Color("f5f5f5")
            if codes.count > index {
                let startIndex = codes.startIndex
                let charIndex = codes.index(startIndex, offsetBy: index)
                let charToString = String(codes[charIndex])
                Text(charToString)
            } else {
                Text(" ")
            }
            
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

struct VerifyCodeView_Previews: PreviewProvider {
    static var previews: some View {
        VerifyCodeView(email: "email", comeBackToRootView: .constant(false))
    }
}
