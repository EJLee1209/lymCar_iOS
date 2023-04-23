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
    
    @State var showExitAlert: Bool = false
    @State var showDeactivateAlert: Bool = false
    @State var showSystemAlert: Bool = false
    @State var systemMsg: String = ""
    
    @StateObject var viewModel = MainViewModel()
    
    @GestureState var dragOffset: CGSize = .zero
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.progress == .loading)) {
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
                                showExitAlert = true
                            } label: {
                                Text("채팅방 나가기")
                            }
                            Button {
                                showDeactivateAlert = true
                            } label: {
                                Text("카풀 마감하기")
                            }

                        } label: {
                            Image("more-vertical")
                        }.padding(10)
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
            .alert("채팅방 나가기", isPresented: $showExitAlert) {
                HStack {
                    Button("확인", role: .destructive) {
                        viewModel.exitRoom(roomId: myRoom.roomId) { result in
                            switch result {
                            case .success(_):
                                self.mapToChatRoom = false
                            case .failure(let errorCode):
                                self.showExitAlert = false
                                self.showSystemAlert = true
                                self.systemMsg = "채팅방 퇴장 실패"
                                print(errorCode.localizedDescription)
                                break
                            }
                        }
                    }
                    Button("취소", role: .cancel) {}
                }
            } message: {
                Text("나가기를 하면 대화내용이\n모두 히스토리에 저장됩니다.\n정말 나가시겠습니까?")
            }
            .alert("카풀 마감하기", isPresented: $showDeactivateAlert) {
                HStack {
                    Button("확인", role: .destructive) {
                        // 마감
                    }
                    Button("취소", role: .cancel) {}
                }
            } message: {
                Text("마감하기를 하면\n인원을 더이상 추가할 수 없습니다.\n마감할까요?")
            }
            .alert("시스템 메세지", isPresented: $showDeactivateAlert) {
                Button("닫기", role: .cancel) {}
            } message: {
                Text(systemMsg)
            }
            .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
                if value.startLocation.x < 20 && value.translation.width > 100 {
                    self.mapToChatRoom = false
                }
            }))
        }
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(myRoom: .constant(CarPoolRoom()), mapToChatRoom: .constant(true))
    }
}
