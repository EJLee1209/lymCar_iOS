//
//  MainView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import SwiftUI
import ComposableArchitecture


enum TabIndex {
    case history, map, menu
}

struct MainView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appDelegate : AppDelegate
    @AppStorage("didLogin") private var didLogin = false
    @StateObject var viewModel = MainViewModel()
    
    @State var tabIndex : TabIndex = .map
    @State var barPosition: CGFloat = 0
    @State var barWidth: CGFloat = 0
    @State var showBottomSheet: Bool = false
    @State var currentUser: User?
    @State var showAlert: Bool = false
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.progress == .loading)) {
            GeometryReader { proxy in
                NavigationView {
                    ZStack(alignment: .bottom) {
                        self.changeFragment()
                        
                        if !showBottomSheet {
                            HStack(spacing: 0) {
                                Button {
                                    tabIndex = .history
                                    changeBarPosition(proxy: proxy)
                                } label: {
                                    Image("message-circle")
                                        .renderingMode(.template)
                                        .foregroundColor(tabIndex == .history ? Color("main_blue") : Color("667080"))
                                        .frame(width: proxy.size.width/3, height: 90)
                                }
                                
                                Button {
                                    tabIndex = .map
                                    changeBarPosition(proxy: proxy)
                                } label: {
                                    Image("map")
                                        .renderingMode(.template)
                                        .foregroundColor(tabIndex == .map ? Color("main_blue") : Color("667080"))
                                        .frame(width: proxy.size.width/3, height: 90)
                                }
                                
                                Button {
                                    tabIndex = .menu
                                    changeBarPosition(proxy: proxy)
                                } label: {
                                    Image("menu")
                                        .renderingMode(.template)
                                        .foregroundColor(tabIndex == .menu ? Color("main_blue") : Color("667080"))
                                        .frame(width: proxy.size.width/3, height: 90)
                                }

                            }
                            .background(Color("white"))
                            .roundedCorner(30, corners: [.topLeft, .topRight])
                            
                            Rectangle()
                                .frame(width: barWidth, height: 4)
                                .foregroundColor(Color("main_blue"))
                                .offset(x: barPosition , y: -86)
                        }

                        
                    }.edgesIgnoringSafeArea(.all)
                        .onAppear {
                            barWidth = proxy.size.width/3
                        }
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .alert("로그인 감지", isPresented: .constant(viewModel.detectAnonymous)) {
                Button(role: .cancel) {
                    dismiss()
                    didLogin=false
                } label: {
                    Text("확인")
                }
            } message: {
                Text("다른 기기에서 로그인했습니다.\n자동으로 로그아웃합니다.")
            }
            .alert("로그아웃 실패", isPresented: $showAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("잠시 후에 다시 시도해주세요")
            }
            .onDisappear {
                viewModel.removeAllRegistration()
                print("mainView onDisapear")
            }
            .onAppear {
                viewModel.updateFcmToken(token: self.appDelegate.fcmToken)
                viewModel.moniteringLogged()
                viewModel.subscribeMyRoom()
                viewModel.subscribeUser()
            }
            .onChange(of: viewModel.myRoom) { newValue in
                viewModel.participantsRegistration?.remove()
                if let safeRoom = newValue {
                    viewModel.subscribeParticipantsTokens(roomId: safeRoom.roomId)
                }
            }
            
        }
    }
    @ViewBuilder
    func changeFragment() -> some View {
        switch self.tabIndex {
        case .history:
            HistoryView()
        case .map:
            MapView(
                showBottomSheet: $showBottomSheet
            )
            .environmentObject(self.viewModel)
            .environmentObject(self.appDelegate)
        case .menu:
            if let currentUser = viewModel.currentUser {
                MenuView(
                    user: .constant(currentUser)
                ) {
                    viewModel.logout { result in
                        switch result {
                        case .success(_):
                            dismiss()
                        case.failure(_):
                            showAlert.toggle()
                        }
                    }
                }
            }
        }
    }
    
    func changeBarPosition(proxy: GeometryProxy) {
        withAnimation {
            switch self.tabIndex {
            case .history:
                barPosition = -proxy.size.width/3
                barWidth = proxy.size.width/3 - 30
            case .map:
                barPosition = 0
                barWidth = proxy.size.width/3
            case .menu:
                barPosition = proxy.size.width/3
                barWidth = proxy.size.width/3 - 30
            }
        }
    }
}



struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(AppDelegate())
    }
}
