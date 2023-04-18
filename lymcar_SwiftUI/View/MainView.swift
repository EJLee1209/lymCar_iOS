//
//  MainView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewModel()
    @Binding var loginStatus: Bool
    
    var body: some View {
        NavigationView {
            Text("메인화면")
        }.alert("로그인 감지", isPresented: .constant(viewModel.detectAnonymous)) {
            Button("확인", role: .cancel) {
                loginStatus = false
            }
        } message: {
            Text("다른 기기에서 로그인했습니다.\n자동으로 로그아웃합니다.")
        }
        
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(loginStatus: .constant(true))
    }
}
