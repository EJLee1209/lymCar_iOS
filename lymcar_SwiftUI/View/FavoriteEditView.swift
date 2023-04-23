//
//  FavoriteEditView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/23.
//

import SwiftUI

struct FavoriteEditView: View {
    @Environment(\.dismiss) var dismiss
    @State var editMode: Bool = false
    @GestureState var dragOffset : CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Button {
                        // 뒤로가기
                        self.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(18)
                            .font(.system(size: 25))
                            .foregroundColor(Color("white"))
                    }
                    Spacer()
                    Text("즐겨찾기 편집")
                        .font(.system(size: 20))
                        .foregroundColor(Color("white"))
                        .bold()
                    Spacer()

                    if !editMode {
                        Button {
                            editMode.toggle()
                        } label: {
                            Text("편집")
                                .font(.system(size: 13))
                                .foregroundColor(Color("white"))
                                .padding(18)

                        }
                    } else {
                        Text("편집").font(.system(size: 13)).padding(18).opacity(0)
                    }
                }
                .padding(.top, 50)
                .background(Color("main_blue"))


                Spacer()
            }

            if editMode {
                Button {
                    // 편집 완료
                    editMode.toggle()
                } label: {
                    RoundedButton(
                        label: "확인",
                        buttonColor: "main_blue",
                        labelColor: "white"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 47)
                .shadow(radius: 3, y:2)
            }
            else {
                NavigationLink {
                    FavoriteMapView()
                        .navigationBarBackButtonHidden()
                } label: {
                    RoundedButton(
                        label: "추가하기",
                        buttonColor: "main_blue",
                        labelColor: "white"
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 47)
                    .shadow(radius: 3, y:2)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color("white"))
        .edgesIgnoringSafeArea(.all)
        .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
            if value.startLocation.x < 20 && value.translation.width > 100 {
                self.dismiss()
            }
            print("\(value.translation)")
        }))
        
    }
}

struct FavoriteEditView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteEditView()
    }
}
