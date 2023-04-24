//
//  FavoriteEditView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/23.
//

import SwiftUI

struct FavoriteEditView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var realmManager = RealmManger()
    @GestureState var dragOffset : CGSize = .zero
    @State var showAlert: Bool = false
    @State var clickedPlace: PlaceForRealm?

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Button {
                        // 뒤로가기
                        self.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .padding(18)
                            .font(.system(size: 25))
                            .foregroundColor(Color("white"))
                    }
                    Spacer()
                    Text("즐겨찾기 편집")
                        .font(.system(size: 20))
                        .foregroundColor(Color("white"))
                        .bold()
                        .padding(.trailing, 36)
                    Spacer()
                }
                .padding(.top, 50)
                .background(Color("main_blue"))
                
                if realmManager.favorites.count > 0 {
                    List {
                        ForEach(realmManager.favorites, id: \.id) { favorite in
                            if !favorite.isInvalidated && !favorite.isFrozen {
                                FavoriteItem(place: favorite)
                                .listRowInsets(.init())
                                
                            }
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                let favoriteToDelete = realmManager.favorites[index]
                                realmManager.deleteFavorite(id: favoriteToDelete.id)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.inset)
                    .refreshable {
                        realmManager.getFavorites()
                    }
                } else {
                    Spacer()
                }
            }

            NavigationLink {
                FavoriteMapView()
                    .navigationBarBackButtonHidden()
                    .environmentObject(realmManager)
            } label: {
                RoundedButton(
                    label: "추가하기",
                    buttonColor: "main_blue",
                    labelColor: "white"
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 47)
                .shadow(radius: 3, y:2)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color("white"))
        .edgesIgnoringSafeArea(.all)
        .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
            if value.startLocation.x < 20 && value.translation.width > 100 {
                self.dismiss()
            }
        }))
        .onAppear {
            realmManager.getFavorites()
        }
    }
}

struct FavoriteEditView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteEditView()
    }
}
