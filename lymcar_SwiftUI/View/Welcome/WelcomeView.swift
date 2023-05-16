//
//  WelcomeView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import ComposableArchitecture

struct WelcomeView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("email") private var email = ""
    @AppStorage("password") private var password = ""
    @AppStorage("didLogin") private var didLogin = false
    
    let store: StoreOf<WelcomeFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
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

                        NavigationLink {
                            LoginView(
                                store: self.store.scope(
                                    state: \.LoginViewState,
                                    action: WelcomeFeature.Action.LoginViewAction
                                )
                            )
                            .environmentObject(appDelegate)
                        } label: {
                            RoundedButton(
                                label: "로그인",
                                buttonColor: "main_blue",
                                labelColor: "white"
                            )
                                .padding(.horizontal, 78)
                        }
                        
                        NavigationLink(isActive: Binding(
                            get: { viewStore.registrationInProgress },
                            set: { viewStore.send(.changedRegistrationInProgress($0)) })
                        ) {
                            EmailVerifyView(
                                goToRootView: Binding(
                                    get: { viewStore.registrationInProgress },
                                    set: { viewStore.send(.changedRegistrationInProgress($0)) }
                                ),
                                store: self.store.scope(
                                    state: \.EmailVerifyState,
                                    action: WelcomeFeature.Action.EmailVerifyAction
                                )
                            )
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
                    
                    if viewStore.isLoading {
                        launchScreenView
                    }
                    
                    // 자동 로그인시 이 navigation link 를 타고 메인화면으로 이동함
                    NavigationLink(isActive: Binding(
                        get: { viewStore.autoLogin },
                        set: { _ in })
                    ) {
                        MainView().navigationBarBackButtonHidden()
                            .environmentObject(appDelegate)
                    } label: {}
                }.edgesIgnoringSafeArea(.all)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .onAppear {
                viewStore.send(.onAppear)
                viewStore.send(.getSavedEmail(email))
                viewStore.send(.getSavedPassword(password))
                if didLogin {
                    // 이전에 로그인했었음
                    viewStore.send(.requestCheckLogged(email))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                        viewStore.send(.changedIsLoading)
                    })
                }
            }
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )

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
        WelcomeView(
            store: Store(initialState: WelcomeFeature.State(), reducer: WelcomeFeature())
        )
        .environmentObject(AppDelegate())
    }
}
