//
//  MainView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import SwiftUI

enum TabIndex {
    case history, map, menu
}

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @Binding var loginStatus: Bool
    
    @State var tabIndex : TabIndex = .map
    @State var barPosition: CGFloat = 0
    @State var barWidth: CGFloat = 0
    @State var showBottomSheet: Bool = false
    
    var body: some View {
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
        }
//        .alert("로그인 감지", isPresented: .constant(viewModel.detectAnonymous)) {
//            Button("확인", role: .cancel) {
//                loginStatus = false
//            }
//        } message: {
//            Text("다른 기기에서 로그인했습니다.\n자동으로 로그아웃합니다.")
//        }
        
        
    }
    
    @ViewBuilder
    func changeFragment() -> some View {
        switch self.tabIndex {
        case .history:
            Fragment(backgroundColor: .blue, title: "히스토리")
        case .map:
            MapView(showBottomSheet: $showBottomSheet)
        case .menu:
            Fragment(backgroundColor: .cyan, title: "메뉴")
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

struct Fragment: View {
    var backgroundColor : Color
    var title: String
    
    var body: some View {
        ZStack{
            backgroundColor
            Text(title)
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundColor(.white)
        }.edgesIgnoringSafeArea(.top)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(loginStatus: .constant(true))
    }
}
