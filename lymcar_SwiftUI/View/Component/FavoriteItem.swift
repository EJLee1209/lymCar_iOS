//
//  FavoriteItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/24.
//

import SwiftUI

struct FavoriteItem: View {
    var place: PlaceForRealm
    
    var body: some View {
        HStack(spacing: 0) {
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(place.place_name)
                        .font(.system(size: 15))
                        .foregroundColor(Color("black"))
                        .fontWeight(.heavy)
                        .padding(.top, 18)
                        .padding(.leading, 13)
                        .lineLimit(1)
                    Text(place.road_address_name)
                        .font(.system(size: 15))
                        .foregroundColor(Color("667080"))
                        .padding(.bottom, 18)
                        .padding(.leading, 13)
                        .lineLimit(1)
                    Divider().frame(height: 0).opacity(0)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("667080"))
                    .padding(.trailing, 16)
            }
            
        }
    }
}

struct FavoriteItem_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteItem(place: PlaceForRealm())
    }
}
