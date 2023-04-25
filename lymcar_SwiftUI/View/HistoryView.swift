//
//  HistoryView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/25.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        ZStack(alignment: .top) {
            Color("main_blue")
            VStack(spacing: 0) {
                Text("히스토리")
                    .font(.system(size: 20))
                    .foregroundColor(Color("white"))
                    .fontWeight(.bold)
                    .padding(.top, 60)
                ZStack(alignment: .topLeading) {
                    Color("white")
                    
                    VStack(spacing: 33) {
                        Image("character")
                        Text("개발 중인 기능입니다")
                            .font(.system(size: 14))
                            .foregroundColor(Color("black"))
                    }
                    .padding(.top, UIScreen.main.bounds.height / 5)
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 26)
                .frame(maxWidth: .infinity)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
