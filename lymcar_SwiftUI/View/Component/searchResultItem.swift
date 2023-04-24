//
//  searchResultItem.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI

struct searchResultItem: View {
    @Binding var editMode: Bool
    var place: Place
    var clickAction: (Place) -> Void
    var deleteAction: (Place) -> Void = { _ in }
    
    var body: some View {
        HStack(spacing: 0) {
            
            if editMode {
                Button {
                    // 즐겨찾기 삭제 action
                    deleteAction(place)
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 24))
                        .foregroundColor(Color("d9d9d9"))
                        .padding(16)
                }
            }

            Button {
                // action
                clickAction(place)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(place.place_name)
                            .font(.system(size: 15))
                            .foregroundColor(Color("black"))
                            .fontWeight(.heavy)
                            .padding(.top, 18)
                            .padding(.leading, editMode ? 0 : 13)
                            .lineLimit(1)
                        Text(place.road_address_name)
                            .font(.system(size: 15))
                            .foregroundColor(Color("667080"))
                            .padding(.bottom, 18)
                            .padding(.leading, editMode ? 0 : 13)
                            .lineLimit(1)
                        Divider().frame(height: 0).opacity(0)
                    }
                    if editMode {
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color("667080"))
                            .padding(.trailing, 16)
                    }
                }
            }
            
        }
    }
}

struct searchResultItem_Previews: PreviewProvider {
    static var previews: some View {
        searchResultItem(editMode: .constant(true), place: Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1")) {_ in
            
        }
    }
}
