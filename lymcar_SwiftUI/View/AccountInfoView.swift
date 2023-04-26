//
//  AccountInfoView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/26.
//

import SwiftUI

struct AccountInfoView: View {
    @Environment(\.dismiss) var dismiss
    @GestureState var dragOffset : CGSize = .zero
    
    @Binding var user: User
    var accountDeleteAction: () -> Void = { }
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack(alignment: .center) {
                Button {
                    self.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 25))
                        .foregroundColor(Color("white"))
                        .padding(.leading, 20)
                        .padding(.bottom, 20)
                }

                Spacer()
                Text("계정정보")
                    .font(.system(size:20))
                    .foregroundColor(Color("white"))
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                    .bold()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
            .padding(.top, 60)
            .background(Color("main_blue"))

            InfoView("이름", user.name)
                .padding(.horizontal, 18)
                .padding(.top, 34)
            InfoView("성별", user.genderKor)
                .padding(.horizontal, 18)
                .padding(.top, 22)
            
            Text("회원 정보는 변경할 수 없습니다")
                .font(.system(size: 12))
                .foregroundColor(Color("667080"))
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
            
            Divider()
                .foregroundColor(Color("d9d9d9"))
                .padding(.top, 14)
                .padding(.horizontal, 16)
            
            Button {
                self.accountDeleteAction()
            } label: {
                HStack{
                    Text("회원탈퇴")
                        .foregroundColor(Color("red"))
                        .font(.system(size: 15))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
            
            Text("")
                .frame(maxWidth: .infinity)
                .frame(height: 1.5)
                .background(Color("f5f5f5"))
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color("white"))
        .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
            if value.startLocation.x < 20 && value.translation.width > 100 {
                self.dismiss()
            }
        }))
        
    }
}

struct AccountInfoView_Previews: PreviewProvider {
    static var previews: some View {
        AccountInfoView(user: .constant(User(uid: "", email: "", name: "이은재", gender: "male")))
    }
}
