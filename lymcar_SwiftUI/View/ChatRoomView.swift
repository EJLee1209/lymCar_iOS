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
    @State var msg: String = ""
    @State var tokensMap: [String:String] = [:]
    
    @EnvironmentObject var viewModel : MainViewModel
    @EnvironmentObject var appDelegate : AppDelegate
    @StateObject var realmManager = RealmManger()
    @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
    @GestureState var dragOffset: CGSize = .zero
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.progress == .loading)) {
            ZStack(alignment: .bottom) {
                Color("main_blue")
                    .onTapGesture { self.hideKeyboard() }
                
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
                    ZStack(alignment:.bottom) {
                        VStack {
                            Text("인원 \(myRoom.userCount)명")
                                .font(.system(size: 15))
                                .padding(.top, 13)
                                .onTapGesture { self.hideKeyboard() }
                            
                            ScrollViewReader { proxy in
                                List {
                                    ForEach(realmManager.messages, id: \.self) { chat in
                                        if !chat.isInvalidated && !chat.isFrozen {
                                            ChatItem(
                                                chat: chat,
                                                user: viewModel.currentUser
                                            )
                                            .listRowInsets(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
                                            .listRowSeparator(.hidden)
                                            .padding(.bottom, 12)
                                            .id(chat)
                                            
                                        }   
                                    }
                                }
                                .listStyle(.plain)
                                .onChange(of: realmManager.messages) { messages in
                                    proxy.scrollTo(messages.last)
                                }
                                .onChange(of: keyboard.isShowing) { newValue in
                                    print("keyboard.isShowing : \(newValue)")
                                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                                        proxy.scrollTo(realmManager.messages.last)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.bottom, 60)
                        .onTapGesture { self.hideKeyboard() }
                        
                        HStack(alignment: .center, spacing: 0) {
                            TextField("채팅으로 약속을 잡으세요" ,text: $msg, axis: .vertical)
                                .lineLimit(1...4)
                                .padding(.horizontal, 10)
                            
                            Button {
                                if !msg.isEmpty {
                                  // 메세지 전송
                                    guard let safeUser = viewModel.currentUser else { return }
                                    let chatToSend = Chat(value: [
                                        "roomId" : myRoom.roomId,
                                        "userId" : safeUser.uid,
                                        "userName" : safeUser.name,
                                        "msg" : self.msg,
                                        "messageType" : CHAT_NORMAL
                                    ])
                                    Task {
                                        DispatchQueue.main.async {
                                            realmManager.saveChat(chat: chatToSend)
                                        }
                                        let result = await viewModel.sendPushMessage(
                                            chat: chatToSend,
                                            receiveTokens: self.tokensMap
                                        )
                                        DispatchQueue.main.async {
                                            if result {
                                                realmManager.updateChat(chat: chatToSend, newState: SEND_STATE_SUCCESS)
                                            }else {
                                                realmManager.updateChat(chat: chatToSend, newState: SEND_STATE_FAIL)
                                            }
                                        }
                                    }
                                    self.msg = ""
                                }
                            } label: {
                                Image("button_send")
                            }
                            .padding(.all, 14)
                        }
                        .background(Color("f5f5f5"))
                        .cornerRadius(30)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 14)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color("white"))
                    .roundedCorner(30, corners: [.topLeft, .topRight])
                    .padding(.top, 24)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .alert("채팅방 나가기", isPresented: $showExitAlert) {
                HStack {
                    
                    Button("확인", role: .destructive) {
                        guard let user = viewModel.currentUser else { return }
                        viewModel.progress = .loading
                        let previousRoom = myRoom
                        let previousTokens = self.tokensMap
                        // 퇴장 메세지 전송
                        viewModel.exitRoom(roomId: myRoom.roomId) { result in
                            switch result {
                            case let .success(_):
                                Task {
                                    async let _ = viewModel.sendPushMessage(
                                        chat: Chat(value: [
                                            "roomId": previousRoom.roomId,
                                            "userId": user.uid,
                                            "userName": user.name,
                                            "msg":"\(user.name)님이 나갔습니다",
                                            "messageType":CHAT_EXIT,
                                            "sendSuccess":SEND_STATE_SUCCESS
                                        ]),
                                        receiveTokens: previousTokens
                                    )
                                    
                                    if(previousRoom.participants.first == user.uid && previousRoom.userCount >= 2) {
                                        // 방장이 나감
                                        let newSuperUser = previousRoom.participants[1]
                                        if let name = await viewModel.findUserName(uid: newSuperUser) {
                                            // 새로운 방장 안내 메세지 전송
                                            async let _ = viewModel.sendPushMessage(
                                                chat: Chat(value: [
                                                    "roomId": previousRoom.roomId,
                                                    "userId": user.uid,
                                                    "userName": user.name,
                                                    "msg":"\(name)님이 방장 입니다",
                                                    "messageType":CHAT_ETC,
                                                    "sendSuccess":SEND_STATE_SUCCESS
                                                ]),
                                                receiveTokens: previousTokens
                                            )
                                        }
                                    }
                                }
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
                        guard let user = viewModel.currentUser else { return }
                        if(myRoom.participants.first != user.uid) {
                            self.showSystemAlert.toggle()
                            self.systemMsg = "방장 권한입니다"
                            return
                        }
                        if(myRoom.closed) {
                            self.showSystemAlert.toggle()
                            self.systemMsg = "이미 마감된 방입니다"
                            return
                        }
                        Task {
                            let isSuccessDeactivate = await viewModel.deactivateRoom(roomId: myRoom.roomId)
                            if(isSuccessDeactivate) {
                                // 마감 성공
                                // 마감 메세지 전송
                                let chat = Chat(value: [
                                    "roomId": myRoom.roomId,
                                    "userId": user.uid,
                                    "userName": user.name,
                                    "msg": "카풀이 마감됐습니다",
                                    "messageType":CHAT_ETC,
                                    "sendSuccess":SEND_STATE_SUCCESS
                                ])
                                await viewModel.sendPushMessage(
                                    chat: chat,
                                    receiveTokens: self.tokensMap
                                )
                                realmManager.saveChat(chat: chat)
                            } else {
                                // 마감 실패
                                self.showSystemAlert.toggle()
                                self.systemMsg = "알 수 없는 오류입니다\n잠시 후 다시 시도해주세요"
                            }
                        }
                    }
                    Button("취소", role: .cancel) {}
                }
            } message: {
                Text("마감하기를 하면\n인원을 더이상 추가할 수 없습니다.\n마감할까요?")
            }
            .alert("시스템 메세지", isPresented: $showSystemAlert) {
                Button { } label: { Text("확인") }

            } message: {
                Text(systemMsg)
            }
            .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
                if value.startLocation.x < 20 && value.translation.width > 100 {
                    self.mapToChatRoom = false
                }
            }))
            .onAppear {
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                UIApplication.shared.removeTapGestureRecognizer()
                realmManager.getChats(roomId: myRoom.roomId)
                appDelegate.realmManager = self.realmManager
                appDelegate.isViewChatRoom = true
                keyboard.addObserver()
                
                var copyTokens = viewModel.participantsTokens
                copyTokens.removeValue(forKey: appDelegate.fcmToken)
                self.tokensMap = copyTokens
            }
            .onDisappear {
                UIApplication.shared.addTapGestureRecognizer()
                keyboard.removeObserver()
                appDelegate.isViewChatRoom = false
            }
            .onChange(of: viewModel.participantsTokens) { tokens in
                var copyTokens = tokens
                copyTokens.removeValue(forKey: appDelegate.fcmToken)
                self.tokensMap = copyTokens
            }
        }
    }
}

struct ChatRoomView_Previews: PreviewProvider {
    static var previews: some View {
        ChatRoomView(myRoom: .constant(CarPoolRoom()), mapToChatRoom: .constant(true))
            .environmentObject(MainViewModel())
            .environmentObject(AppDelegate())
    }
}
