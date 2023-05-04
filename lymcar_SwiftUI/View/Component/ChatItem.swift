//
//  ChatItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/04.
//

import SwiftUI

struct ChatItem: View {
    var chat: Chat
    
    var body: some View {
        YourChat(chat)
    }
}

@ViewBuilder
func MyChat(_ chat: Chat) -> some View {
    
    HStack(alignment:.bottom ,spacing: 8) {
        Spacer()
        Text(chat.dateTime.getPrettyHour())
            .font(.system(size: 11))
            .foregroundColor(Color("main_blue"))
        Text(chat.msg)
            .font(.system(size: 13))
            .foregroundColor(Color("white"))
            .padding(.horizontal, 24)
            .padding(.vertical, 7)
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
                .padding(.horizontal, 24)
                .padding(.vertical, 7)
                .background(Color("f5f5f5"))
                .roundedCorner(20, corners: [.topLeft, .topRight, .bottomRight])
            Text(chat.dateTime.getPrettyHour())
                .font(.system(size: 11))
                .foregroundColor(Color("main_blue"))
            Spacer()
        }
    }
}

struct ChatItem_Previews: PreviewProvider {
    static var previews: some View {
        ChatItem(chat: Chat())
    }
}
