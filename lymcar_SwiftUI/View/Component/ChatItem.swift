//
//  ChatItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/04.
//

import SwiftUI

struct ChatItem: View {
    var chat: Chat
    var user: User?
    
    var body: some View {
        if (chat.messageType == CHAT_ETC || chat.messageType == CHAT_EXIT || chat.messageType == CHAT_JOIN) {
            EnterMessage(chat)
        } else {
            if let safeUser = user {
                if (chat.userId == safeUser.uid) {
                    MyChat(chat)
                }
                else {
                    YourChat(chat)
                }
            } 
        }
        
    }
}

@ViewBuilder
func MyChat(_ chat: Chat) -> some View {
    HStack(alignment:.bottom ,spacing: 8) {
        Spacer()
        Text(chat.dateTime.getPrettyHour(sep: " "))
            .font(.system(size: 11))
            .foregroundColor(Color("main_blue"))
        Text(chat.msg)
            .font(.system(size: 13))
            .foregroundColor(Color("white"))
            .padding(12)
            .background(Color("main_blue"))
            .roundedCorner(20, corners: [.topLeft, .topRight, .bottomLeft])
    }
}
@ViewBuilder
func YourChat(_ chat: Chat) -> some View {
    VStack(alignment:.leading, spacing: 4) {
        Text(chat.userName)
            .font(.system(size: 13))
            .foregroundColor(Color("black"))
        HStack(alignment:.bottom ,spacing: 8) {
            Text(chat.msg)
                .font(.system(size: 13))
                .foregroundColor(Color("black"))
                .padding(12)
                .background(Color("f5f5f5"))
                .roundedCorner(20, corners: [.topLeft, .topRight, .bottomRight])
            Text(chat.dateTime.getPrettyHour(sep: " "))
                .font(.system(size: 11))
                .foregroundColor(Color("main_blue"))
            Spacer()
        }
    }
}

@ViewBuilder
func EnterMessage(_ chat: Chat) -> some View {
    // Enter or Exit message item
    Text(chat.msg)
        .font(.system(size: 11))
        .foregroundColor(Color("667080"))
        .frame(maxWidth: .infinity)
}

struct ChatItem_Previews: PreviewProvider {
    static var previews: some View {
        ChatItem(chat: Chat(
            value: [
                "msg" : "- 개발자님이 입장하셨습니다 -"
                
            ]
        ), user: User(uid: "", email: "", name: "은재", gender: "")
        )
    }
}
