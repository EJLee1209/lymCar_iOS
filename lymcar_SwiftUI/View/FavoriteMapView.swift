//
//  FavoriteMapView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/23.
//

import SwiftUI
import _MapKit_SwiftUI
import PopupView

struct FavoriteMapView: View {
    @Environment(\.dismiss) var dismiss
    private let manager = CLLocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.8856353, longitude: 127.7383948),
        span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
    )
    @State var points : [Point] = [
        Point(name: "", coordinate: .init(latitude: 0, longitude: 0), image: "", isDummy: true)
    ]
    @State var placeName: String = ""
    @State var place: Place?
    @State var expandBottomSheet: Bool = false
    @State var dragOffSet : CGSize = .zero
    @State var searchResults = [Place]()
    @State var showAlert: Bool = false
    @State var showingPopup = false

    @StateObject var viewModel = MainViewModel()
    @GestureState var dragOffset : CGSize = .zero
    @EnvironmentObject var realmManager: RealmManger
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Button {
                        // 뒤로가기
                        self.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 25))
                            .padding(18)
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

                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: points) { point in
                    MapAnnotation(coordinate: point.coordinate) {
                        Image(point.image)
                    }
                }.onAppear {
                    manager.requestWhenInUseAuthorization()
                    manager.startUpdatingLocation()
                    region.center = manager.location?.coordinate ?? region.center
                }
                Spacer()
            }
            .onTapGesture {
                withAnimation {
                    expandBottomSheet = false
                }
            }
            
            ZStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    HStack(spacing: 9) {
                        Text((place == nil ? "한림대학교" : place?.place_name) ?? "한림대학교")
                            .font(.system(size: 24))
                            .foregroundColor(Color("black"))
                            .fontWeight(.heavy)
                        Image("edit")
                    }

                    HStack(spacing: 0) {
                        TextField(
                            "즐겨찾기를 등록할 장소를 검색해주세요",
                            text: $placeName
                        )
                        .font(.system(size: 14))
                        .foregroundColor(Color("667080"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal,15)
                        .submitLabel(.search)
                        .onSubmit {
                            // 검색
                            viewModel.searchPlace(keyword: placeName)
                        }
                        .onTapGesture {
                            withAnimation {
                                expandBottomSheet = true
                            }
                            placeName = ""
                        }

                        Spacer()
                        Button {
                            viewModel.searchPlace(keyword: placeName)
                        } label: {
                            Image("search")
                        }
                        .padding(.trailing, 15)

                    }
                    .background(Color("f5f5f5"))
                    .cornerRadius(15)

                    if !expandBottomSheet {
                        Button {
                            if let place = place {
                                // 즐찾 저장
                                realmManager.addFavorite(place: place)
                                showingPopup = true
                            } else {
                                showAlert = true
                            }
                        } label: {
                            RoundedButton(label: "확인", buttonColor: "main_blue", labelColor: "white")
                        }
                        .padding(.top, 20)
                    }
                    List(searchResults, id: \.self) { result in
                        searchResultItem(
                            editMode: .constant(false),
                            place: result
                        ) { clickedPlace in
                            self.placeName = clickedPlace.address_name
                            self.place = clickedPlace

                            let coordinate = CLLocationCoordinate2D(
                                latitude: Double(clickedPlace.y) ?? 0,
                                longitude: Double(clickedPlace.x) ?? 0
                            )

                            points[0] = Point(
                                name: clickedPlace.place_name,
                                coordinate: coordinate,
                                image: "map_pin_blue"
                            )
                            region.center = CLLocationCoordinate2D(
                                latitude: coordinate.latitude - 0.002,
                                longitude: coordinate.longitude
                            )

                            withAnimation {
                                expandBottomSheet = false
                            }
                        }
                    }.listStyle(.inset)

                    Spacer()
                }
                .padding(.top, 26)
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height / 1.7)
            .background(Color("white"))
            .roundedCorner(30, corners: [.topLeft, .topRight])
            .offset(y: getBottomSheetOffSet())
            .shadow(radius: 3)
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color("white"))
        .onChange(of: viewModel.searchResult) { newValue in
            switch newValue {
            case .success(let result):
                self.searchResults = result.documents
                withAnimation {
                    self.expandBottomSheet = true
                }
            default:
                break
            }
        }
        .alert("즐겨찾기 편집", isPresented: $showAlert) {

        } message: {
            Text("즐겨찾기를 등록할 장소를 검색한 후\n확인 버튼을 눌러주세요")
        }
        
        .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
            if value.startLocation.x < 20 && value.translation.width > 100 {
                self.dismiss()
            }
        }))
        .popup(isPresented: $showingPopup) {
            if let place = place {
                Text("\(place.place_name)\n즐겨찾기로 등록되었습니다")
                    .font(.system(size:13))
                    .foregroundColor(Color("main_blue"))
                    .bold()
                    .multilineTextAlignment(.center)
                    .frame(width: 200, height: 60)
                    .background(Color("white"))
                    .cornerRadius(30)
                    .overlay {
                        RoundedCornerShape()
                            .stroke(lineWidth: 5)
                            .cornerRadius(30)
                            .foregroundColor(Color("main_blue"))
                    }
                    
                    
            }
            
        } customize: {
            $0.autohideIn(2)
                .type(.floater())
                .position(.top)
                .animation(.spring())
                .closeOnTapOutside(true)
                .backgroundColor(.black.opacity(0.5))
        }
    }
    
    private func getBottomSheetOffSet() -> CGFloat {
        if expandBottomSheet {
            return 0
        } else {
            return UIScreen.main.bounds.height / 1.7 - 227
        }
    }
}

struct FavoriteMapView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteMapView()
            .environmentObject(RealmManger())
    }
}
