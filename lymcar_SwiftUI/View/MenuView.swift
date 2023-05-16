//
//  MenuView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/23.
//

import SwiftUI

struct MenuView: View {
    @Binding var user: User
    var clickedLogout: () -> Void = {}
    @State var showAlert: Bool = false
    @AppStorage("didLogin") private var didLogin = false
    
    private func getGender() -> String {
        switch user.gender {
        case Constants.GENDER_OPTION_MALE:
            return "남성"
        case Constants.GENDER_OPTION_FEMALE:
            return "여성"
        default:
            return "성별 선택 안함"
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color("main_blue")
            
            VStack(spacing: 0) {
                Text("메뉴")
                    .font(.system(size:20))
                    .foregroundColor(Color("white"))
                    .bold()
                
                VStack(alignment: .leading, spacing: 0) {
                    Group {
                        Text("안녕하세요,\n\(user.name)님.")
                            .font(.system(size: 24))
                            .foregroundColor(Color("black"))
                            .fontWeight(.heavy)
                            .padding(.top, 46)
                            .padding(.leading, 21)
                        
                        HStack(spacing: 3) {
                            Text(getGender())
                                .font(.system(size: 15))
                                .foregroundColor(Color("667080"))
                            Rectangle()
                                .frame(width: 1.5, height: 15)
                                .foregroundColor(Color("667080"))
                            Text(user.email)
                                .font(.system(size: 15))
                                .foregroundColor(Color("667080"))
                            
                        }
                        .padding(.leading, 21)
                        .padding(.top, 6)
                    }
                    Divider().padding(.top, 32)
                    
                    Group {
                        NavigationLink {
                            AccountInfoView(user: $user)
                                .navigationBarBackButtonHidden()
                        } label: {
                            HStack(alignment: .center, spacing: 17) {
                                Image("user")
                                Text("계정 정보")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("667080"))
                                Spacer()
                            }
                            .padding(.leading, 20)
                            .padding(.vertical, 11)
                        }
                        Divider()
                        NavigationLink {
                            FavoriteEditView()
                                .navigationBarBackButtonHidden()
                        } label: {
                            HStack(alignment: .center, spacing: 17) {
                                Image("map-pin")
                                Text("즐겨찾기 편집")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("667080"))
                                Spacer()
                            }
                            .padding(.leading, 20)
                            .padding(.vertical, 11)
                        }
                        
                        
                        Rectangle()
                            .frame(height: 10)
                            .foregroundColor(Color("f5f5f5"))
                        
                        Button {
                            // 업데이트 확인
                            
                        } label: {
                            HStack {
                                Text("업데이트 정보")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("667080"))
                                Spacer()
                                Text("최신 버전 입니다.")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color("d9d9d9"))
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                        }
                        Divider()
                        Button {
                            // 개인정보 취급방침
                            var stringUrl = Bundle.main.privacyPolicyUrl
                            guard let url = URL(string: stringUrl) else { return }
                            UIApplication.shared.open(url, options: [:])
                        } label: {
                            HStack {
                                Text("개인정보 취급방침")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("667080"))
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 15)
                        }
                        
                        Rectangle()
                            .frame(height: 10)
                            .foregroundColor(Color("f5f5f5"))
                        
                        Button {
                            // 로그아웃
                            showAlert.toggle()
                        } label: {
                            HStack {
                                Text("로그아웃")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("red"))
                                    .padding(.leading, 20)
                                    .padding(.vertical, 15)
                                Spacer()
                            }
                        }

                        Divider()
                    }
                    
                    Divider().frame(height: 0).opacity(0)
                    Spacer()
                }
                .background(Color("white"))
                .padding(.top, 26)
                
                
            }.padding(.top, 60)
        }
        .edgesIgnoringSafeArea(.all)
        .alert("로그아웃", isPresented: $showAlert) {
            Button("확인", role: .destructive) {
                clickedLogout()
                didLogin = false
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("로그아웃 하시겠습니까?")
                .padding(.top)
        }

        
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(user: .constant(User(uid: "", email: "20185158@hallym.ac.kr", name: "은재", gender: Constants.GENDER_OPTION_MALE)))
    }
}
