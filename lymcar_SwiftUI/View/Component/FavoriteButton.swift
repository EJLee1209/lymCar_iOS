//
//  FavoriteButton.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/25.
//

import SwiftUI

struct FavoriteButton: View {
    var favorite: Place
    var clickAction: () -> Void = {}
    var body: some View {
        Button {
            // 즐찾 action
            clickAction()
        } label: {
            Text(favorite.place_name)
                .font(.system(size:14))
                .foregroundColor(Color("black"))
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
                .background(Color("white"))
                .cornerRadius(50)
                .overlay {
                    RoundedCornerShape().stroke(lineWidth: 1).foregroundColor(Color("main_blue"))
                }
                .shadow(radius: 1, y:1)
        }
    }
}

struct FavoriteButton_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteButton(favorite: Place())
    }
}
