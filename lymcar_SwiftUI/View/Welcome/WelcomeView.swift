//
//  WelcomeView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

struct WelcomeView: View {
    @State var registrationInProgress = false
    @State var loginStatus = false
    
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
            }.edgesIgnoringSafeArea(.all)
        }
        
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
