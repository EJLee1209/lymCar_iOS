//
//  ChatRoomView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/22.
//

import SwiftUI

struct ChatRoomView: View {
    @Binding var myRoom: CarPoolRoom
    @Binding var mapToChatRoom: Bool
    @State var showAlert: Bool = false
    @State var alertTitle: String = ""
    @State var alertMsg: String = ""
    var body: some View {
        ZStack(alignment: .bottom) {
            Color("main_blue")
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        // 뒤로가기
                        self.mapToChatRoom = false
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(10)
                            .font(.system(size: 25))
                            .foregroundColor(Color("white"))
                    }
                    Spacer()
                    Text("\(myRoom.startPlace.place_name) - \(myRoom.endPlace.place_name)")
                        .font(.system(size:20))
                        .lineLimit(1)
                        .bold()
                        .foregroundColor(Color("white"))
                    Spacer()
                    Menu {
                        Button {
                            showAlert = true
                            alertTitle = "채팅방 나가기"
                            alertMsg = "나가기를 하면 대화내용이\n모두 히스토리에 저장됩니다.\n정말 나가시겠습니까?"
                        } label: {
                            Text("채팅방 나가기")
                        }
                        Button {
                            showAlert = true
                            alertTitle = "카풀 마감하기"
                            alertMsg = "마감하기를 하면\n인원을 더이상 추가할 수 없습니다.\n마감할까요?"
                        } label: {
                            Text("카풀 마감하기")
                        }

                    } label: {
                        Image("more-vertical")
                    }.padding(10)
                        .alert(alertTitle, isPresented: $showAlert) {
                            HStack {
                                Button("확인", role: .destructive) {
                                    
                                }
                                Button("취소", role: .cancel) {}
                            }
                        } message: {
                            Text(alertMsg)
                        }

                    
                }
                .padding(.top, 50)
                .padding(.horizontal, 10)
                ZStack {
                    VStack {
                        Text("인원 \(myRoom.userCount)명")
                            .font(.system(size: 15))
                            .padding(.top, 13)
                        
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color("white"))
                .roundedCorner(30, corners: [.topLeft, .topRight])
                .padding(.top, 24)
            }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(myRoom: .constant(CarPoolRoom()), mapToChatRoom: .constant(true))
    }
}
