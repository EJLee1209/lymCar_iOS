//
//  ModalView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI

struct SearchResultModal: View {
    @Binding var documents: [Place]
    var clickAction: (Place) -> Void
    
    var body: some View {
        VStack(alignment:.leading, spacing:10){
            Text("장소")
                .font(.system(size:20))
                .foregroundColor(Color("black"))
                .fontWeight(.heavy)
            
            if documents.isEmpty {
                Spacer()
                Text("검색결과 없음")
                    .font(.system(size: 25))
                    .frame(maxWidth: .infinity)
                Spacer()
            }
            else{
                List(documents, id: \.self) { place in
                    searchResultItem(
                        place: Place(
                            place_name : place.place_name,
                            road_address_name : place.road_address_name
                        )
                    ) { place in
                        clickAction(place)
                    }
                }.roundedCorner(30, corners: [.topLeft, .topRight])
                    .edgesIgnoringSafeArea(.all)
                    .listStyle(.inset)
            }
            
            Divider().frame(height: 0).opacity(0)
            Spacer()
        }
        .edgesIgnoringSafeArea(.all)
        .padding(.top, 20)
        .padding(.horizontal, 22)
        
        
    }
}

struct SearchResultModal_Previews: PreviewProvider {
    
    static var previews: some View {
        SearchResultModal(documents: .constant(
            [
//                Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1"),
//                Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1"),
//                Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1"),
//                Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1"),
//                Place(place_name: "한림대학교", road_address_name: "강원도 춘천시 한림대학길 1")
            ]
        )) { place in
            
        }
    }
}
