//
//  MapView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI
import MapKit

struct Point: Identifiable {
    var id: UUID = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var image: String
    var isDummy: Bool = false
}

struct MapView: View {
    @Binding var showBottomSheet: Bool // bottomSheet visibility
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.88371, longitude: 127.73947),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State var startPlaceName: String = ""
    @State var endPlaceName: String = ""
    @State var placeList = [Place]()
    @State var startPlace: Place?
    @State var endPlace: Place?
    @State var searchField: SearchField?
    @State var showModal: Bool = false // 장소 검색 결과 모달 visibility
    @State var showMyRoomBox: Bool = false
    @State var myRoom: CarPoolRoom? = nil
    @State var points : [Point] = [
        Point(name: "", coordinate: .init(latitude: 0, longitude: 0), image: "", isDummy: true),
        Point(name: "", coordinate: .init(latitude: 0, longitude: 0), image: "", isDummy: true)
    ]
    
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.searchResult == .loading)) {
            ZStack(alignment: .top) {
                // 애플 지도
                Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: points) { point in
                    MapAnnotation(coordinate: point.coordinate) {
                        Image(point.image)
                    }
                }.onTapGesture {
                    if showBottomSheet {
                        showBottomSheet.toggle()
                    }
                }.onAppear {
                    let manager = CLLocationManager()
                    manager.requestWhenInUseAuthorization()
                    manager.startUpdatingLocation()
                }
                
                // SearchView(검색뷰) , 카풀 목록 보기 버튼
                VStack(spacing: 9) {
                    SearchView(startPlaceName: $startPlaceName, endPlaceName: $endPlaceName){ searchField in
                        // submit action
                        showModal = true
                        self.searchField = searchField
                        switch searchField {
                        case .start:
                            viewModel.searchPlace(keyword: startPlaceName)
                        case .end:
                            viewModel.searchPlace(keyword: endPlaceName)
                        }
                    }
                    Spacer()
                    Button {
                        // 카풀 목록 보기
                        self.showBottomSheet.toggle()
                    } label: {
                        Text("카풀 목록 보기")
                            .font(.system(size: 11))
                            .foregroundColor(Color("main_blue"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(Color("white"))
                            .cornerRadius(35)
                            .overlay {
                                RoundedRectangle(cornerRadius: 35)
                                    .stroke().foregroundColor(Color("main_blue"))
                            }
                    }
                    .padding(.bottom, showMyRoomBox ? 9 : 104)
                    
                    if showMyRoomBox {
                        MyRoomBox(room: myRoom!)
                            .padding(.bottom, 102)
                    }
                }
                .padding(.top, 60)
                .padding(.horizontal, 12)
                .onTapGesture {
                    if showBottomSheet {
                        showBottomSheet.toggle()
                    }
                }
                
                // bottomSheet
                GeometryReader { proxy in
                    VStack(alignment: .trailing) {
                        Spacer()
                        
                        // 새로고침 버튼
                        Button {
                            // action
                            
                        } label: {
                            Image("refresh")
                                .padding(.all, 13)
                        }
                        .background(Color("white"))
                        .clipShape(Circle())
                        .shadow(radius: 3, y: 5)
                        .padding(.trailing, 15)
                        .padding(.bottom, 11)

                        ZStack(alignment: .topLeading) {
                            Color("white")
                            VStack(spacing: 14) {
                                HStack {
                                    Text("카풀 목록")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("black"))
                                        .fontWeight(.heavy)
                                    Spacer()
                                    Button {
                                        // 방 생성 Action
                                        
                                    } label: {
                                        Image("plus")
                                            .padding(.all, 18)
                                    }
                                    .padding(.trailing, 4)
                                }
                                
                                Image("character")
                                Text("+버튼을 눌러\n첫번째 채팅방을 생성해보세요!")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size:16))
                                    .foregroundColor(Color("black"))

                            }
                            .padding(.leading, 22)
                            
                        }
                        .roundedCorner(30, corners: [.topLeft, .topRight])
                        
                    }
                    .frame(
                        width: proxy.size.width,
                        height: 400,
                        alignment: .center
                    )
                    .offset(y: bottomSheetOffSet(proxy: proxy))
                    .animation(.easeOut(duration: 0.3), value: self.showBottomSheet)
                }
                
            }.edgesIgnoringSafeArea(.all)
                .sheet(isPresented: $showModal) {
                    SearchResultModal(documents: $placeList) { place in
                        if searchField == .start {
                            startPlace = place
                            startPlaceName = place.road_address_name
                            addPoint(place, true)
                        }
                        if searchField == .end {
                            endPlace = place
                            endPlaceName = place.road_address_name
                            addPoint(place, false)
                        }
                        showModal = false
                    }
                }
                .onChange(of: viewModel.searchResult) { newValue in
                    switch newValue {
                    case .success(let result):
                        placeList = result.documents
                    case .failure(let msg):
                        print(msg)
                    default:
                        break
                    }
                }
                .onAppear{
                    viewModel.subscribeMyRoom { result in
                        switch result {
                        case .success(let room):
                            if let safeRoom = room {
                                self.showMyRoomBox = true
                                self.myRoom = safeRoom
                            } else {
                                self.showMyRoomBox = false
                                self.myRoom = nil
                            }
                            
                        default:
                            break
                        }
                    }
                }
                .onDisappear {
                    viewModel.removeRegistration()
                }
        }
        
    }
    
    fileprivate func moveCamera() {
        let latDistance = abs(points[0].coordinate.latitude.distance(to: points[1].coordinate.latitude))
        let lonDistance = abs(points[0].coordinate.longitude.distance(to: points[1].coordinate.longitude))
        
        self.region.span = .init(latitudeDelta: latDistance * 1.5 , longitudeDelta: lonDistance * 1.5)
        
        showBottomSheet.toggle()
    }
    
    private func addPoint(_ place: Place, _ isStartPlace: Bool) {
        let location = CLLocationCoordinate2D.init(
            latitude: Double(place.y) ?? 0 ,
            longitude: Double(place.x) ?? 0
        )
        let newPoint: Point
        if isStartPlace {
            newPoint = Point(
                name: place.place_name,
                coordinate: location,
                image: "marker_start"
            )
            self.points[0] = newPoint
            if points[1].isDummy {
                self.region.center = newPoint.coordinate
            } else {
                let centerLat = (points[0].coordinate.latitude + points[1].coordinate.latitude) / 2
                let centerLon = (points[0].coordinate.longitude + points[1].coordinate.longitude) / 2
                let centerCoord = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
                self.region.center = centerCoord
                
                moveCamera()
            }
            
        } else {
            newPoint = Point(
                name: place.place_name,
                coordinate: location,
                image: "marker_end"
            )
            self.points[1] = newPoint
            if points[0].isDummy {
                self.region.center = newPoint.coordinate
            } else {
                let centerLat = (points[0].coordinate.latitude + points[1].coordinate.latitude) / 2
                let centerLon = (points[0].coordinate.longitude + points[1].coordinate.longitude) / 2
                let centerCoord = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon)
                self.region.center = centerCoord
                
                moveCamera()
            }
        }
    }
    
    private func bottomSheetOffSet(proxy: GeometryProxy) -> CGFloat {
        return showBottomSheet ? proxy.size.height-400 : proxy.size.height
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(showBottomSheet: .constant(false))
    }
}
