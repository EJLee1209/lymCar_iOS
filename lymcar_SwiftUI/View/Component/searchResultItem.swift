//
//  searchResultItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI

struct searchResultItem: View {
    var place: Place
    var clickAction: (Place) -> Void
    
    var body: some View {
        Button {
            // action
            clickAction(place)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                Text(place.place_name)
                    .font(.system(size: 15))
                    .foregroundColor(Color("black"))
                    .fontWeight(.heavy)
                    .padding(.top, 13)
                    .padding(.horizontal, 15)
                Text(place.road_address_name)
                    .font(.system(size: 15))
                    .foregroundColor(Color("667080"))
                    .padding(.bottom, 16)
                    .padding(.horizontal, 15)
            }
        }

    }
}

struct searchResultItem_Previews: PreviewProvider {
    static var previews: some View {
        searchResultItem(place: Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1")) {_ in
            
        }
    }
}
