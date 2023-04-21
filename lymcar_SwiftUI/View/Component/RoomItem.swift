//
//  RoomItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/21.
//

import SwiftUI

struct RoomItem: View {
    var isMyRoom: Bool = false
    var room: CarPoolRoom
    
    var body: some View {
        Button {
            // 채팅방 입장 action
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(room.startPlace.place_name)
                    .font(.system(size:20))
                    .foregroundColor(isMyRoom ? Color("white") : Color("black"))
                    .bold()
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Image("down_right_arrow")
                        .renderingMode(.template)
                        .foregroundColor(isMyRoom ? Color("white") : Color("main_blue"))
                    Text(room.endPlace.place_name)
                        .font(.system(size:20))
                        .foregroundColor(isMyRoom ? Color("white") : Color("black"))
                        .bold()
                        .lineLimit(2)
                }.padding(.top, 9)
                
                Text("\(room.genderOption)끼리 탑승하기")
                    .font(.system(size:13))
                    .foregroundColor(isMyRoom ? Color("white") : Color("black"))
                    .padding(.top, 13)
                    
                Text(room.departureTime)
                    .font(.system(size:13))
                    .foregroundColor(isMyRoom ? Color("white") : Color("black"))
                
                Spacer()
                HStack {
                    Text("지금 위치에서\n5m")
                        .font(.system(size:10))
                        .foregroundColor(isMyRoom ? Color("white") : Color("main_blue"))
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("\(room.userCount)/\(room.userMaxCount)")
                        .font(.system(size: 36))
                        .foregroundColor(isMyRoom ? Color("white") : Color("main_blue"))
                        .fontWeight(.heavy)
                }
            }
            .padding(14)
            .frame(width: 180, height: 225)
            .background(isMyRoom ? Color("main_blue") : Color("white"))
            .cornerRadius(10)
            .shadow(radius: 3, y:3)
        }
    }
}

struct RoomItem_Previews: PreviewProvider {
    static var previews: some View {
        RoomItem(room: CarPoolRoom())
    }
}
