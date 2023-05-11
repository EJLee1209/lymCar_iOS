//
//  MyRoomView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/21.
//

import SwiftUI

struct MyRoomBox: View {
    @Binding var room: CarPoolRoom?
    var clickAction: () -> Void = {}
    
    var body: some View {
        
        Button {
            clickAction()
        } label: {
            if let room = room {
                HStack(alignment: .top, spacing: 0) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(room.startPlace.place_name)
                            .font(.system(size: 15))
                            .foregroundColor(Color("white"))
                            .fontWeight(.heavy)
                        HStack(spacing: 6) {
                            Image("down_right_arrow")
                            Text(room.endPlace.place_name)
                                .foregroundColor(Color("white"))
                                .fontWeight(.heavy)
                        }
                    }
                    Spacer()
                    
                    VStack(alignment: .trailing,spacing: 0) {
                        Text(Utils.getPrettyDateTime(dateTime: room.departureTime))
                            .font(.system(size: 12))
                            .foregroundColor(Color("white"))
                        Text("\(room.userCount)/\(room.userMaxCount)")
                            .font(.system(size: 24))
                            .foregroundColor(Color("white"))
                            .fontWeight(.heavy)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color("main_blue"))
                .cornerRadius(10)
            }
        }
    }
}

struct MyRoomBox_Previews: PreviewProvider {
    static var previews: some View {
        MyRoomBox(room: .constant(CarPoolRoom()))
    }
}
