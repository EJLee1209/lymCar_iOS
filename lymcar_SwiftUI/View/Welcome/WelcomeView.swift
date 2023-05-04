//
//  WelcomeView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("email") private var email = ""
    @AppStorage("password") private var password = ""
    @AppStorage("didLogin") private var didLogin = false
    
    @State var registrationInProgress = false
    @State var loginStatus = false
    @State var autoLogin = false
    @State var isLoading = true
    @State var showAlert = false
    @StateObject var viewModel = WelcomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                Image("welcomeBg")
                    .resizable()
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome!")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .padding(.leading, 21)
                    Text("림카에 오신걸 환영합니다")
                        .foregroundColor(.white)
                        .font(.system(size: 15))
                        .padding(.top, 10)
                        .padding(.leading, 21)
                    Spacer()

                    NavigationLink(isActive: $loginStatus) {
                        LoginView(loginStatus: $loginStatus)
                            .environmentObject(viewModel)
                    } label: {
                        RoundedButton(
                            label: "로그인",
                            buttonColor: "main_blue",
                            labelColor: "white"
                        )
                            .padding(.horizontal, 78)
                    }

                    NavigationLink(isActive: $registrationInProgress) {
                        EmailVerifyView(comeBackToRootView: $registrationInProgress)
                    } label: {
                        RoundedButton(
                            label: "회원가입",
                            buttonColor: "white",
                            labelColor: "main_blue"
                        )
                            .padding(.bottom, 105)
                            .padding(.top, 12)
                            .padding(.horizontal, 78)
                    }
                }
                .padding(.top, 137)
                
                if isLoading {
                    launchScreenView
                }
                
                // 자동 로그인시 이 navigation link 를 타고 메인화면으로 이동함
                NavigationLink(isActive: $autoLogin) {
                    MainView(loginStatus: $autoLogin).navigationBarBackButtonHidden()
                } label: {}
            }.edgesIgnoringSafeArea(.all)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            if didLogin {
                // 이전에 로그인했었음
                Task {
                    await viewModel.checkLogged(email: email)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.isLoading.toggle()
                })
            }
            
        }
        .onChange(of: viewModel.authResult) { newValue in
            switch newValue {
            case .failure(let msg):
                // 이미 로그인한 기기가 있거나 로그인 실패
                showAlert = true
            case .success(let msg):
                if msg == Constants.LOGIN_POSSIBLE {
                    // 로그인 가능
                    viewModel.login(email: email, password: password)
                }
                if msg == Constants.LOGIN_SUCCESS {
                    // 로그인 성공
                    autoLogin = true
                    isLoading.toggle()
                }
            default:
                break
            }
        }
        .alert("로그인 실패", isPresented: $showAlert) {
            Button("확인", role: .cancel) {
                isLoading.toggle()
                didLogin = false
            }
        } message: {
            Text("다른기기에서 로그인하여\n자동 로그아웃 처리 되었습니다")
                .padding(.top)
        }
        
    }
}

extension WelcomeView {
    var launchScreenView: some View {
        ZStack(alignment: .center) {
            Color("3051a2")
            Image("app_logo")
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
