//
//  RoomItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/21.
//

import SwiftUI
import CoreLocation

struct RoomItem: View {
    var isMyRoom: Bool = false
    var room: CarPoolRoom
    var location: CLLocationCoordinate2D?
    
    @State var distance: Int = 0
    
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
                
                Text(genderOptionWrapper())
                    .font(.system(size:13))
                    .foregroundColor(isMyRoom ? Color("white") : Color("black"))
                    .padding(.top, 13)
                    
                Text(Utils.getPrettyDateTime(dateTime: room.departureTime))
                    .font(.system(size:13))
                    .foregroundColor(isMyRoom ? Color("white") : Color("black"))
                
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 0){
                        Text("지금 위치에서")
                            .font(.system(size:10))
                            .foregroundColor(isMyRoom ? Color("white") : Color("main_blue"))
                        Text(distance < 100000 ? "\(distance)m" : "100km 이상")
                            .font(.system(size:13))
                            .bold()
                            .foregroundColor(isMyRoom ? Color("white") : Color("main_blue"))
                            .multilineTextAlignment(.leading)
                    }
                    
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
            .onAppear {
                guard let safeLocation = location else {
                    return
                }
                let coordinate1 = CLLocation(latitude: safeLocation.latitude, longitude: safeLocation.longitude)
                let coordinate2 = CLLocation(latitude: room.startPlace.y, longitude: room.startPlace.x)
                
                self.distance = Int(coordinate1.distance(from: coordinate2))
            }
        }
    }
    
    private func genderOptionWrapper() -> String {
        switch room.genderOption {
        case Constants.GENDER_OPTION_MALE:
            return "남성끼리 탑승하기"
        case Constants.GENDER_OPTION_FEMALE:
            return "여성끼리 탑승하기"
        default:
            return "상관없이 탑승하기"
        }
    }
}

struct RoomItem_Previews: PreviewProvider {
    static var previews: some View {
        RoomItem(room: CarPoolRoom(), location: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }
}
