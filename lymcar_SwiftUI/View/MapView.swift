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
    private let manager = CLLocationManager()
    @Binding var showBottomSheet: Bool // bottomSheet visibility
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.8856353, longitude: 127.7383948),
        span: MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006)
    )
    @State var startPlaceName: String = ""
    @State var endPlaceName: String = ""
    @State var placeList = [Place]()
    @State var startPlace: Place?
    @State var endPlace: Place?
    @State var searchField: SearchField?
    @State var showModal: Bool = false // 장소 검색 결과 모달 visibility
    @State var showMyRoomBox: Bool = false
    @State var myRoom: CarPoolRoom?
    @State var points : [Point] = [
        Point(name: "", coordinate: .init(latitude: 0, longitude: 0), image: "", isDummy: true),
        Point(name: "", coordinate: .init(latitude: 0, longitude: 0), image: "", isDummy: true)
    ]
    @State var isExpanded: Bool = false
    @State var poolList: [CarPoolRoom] = []
    @State var showAlert: Bool = false
    @State var alertMsg: String = ""
    
    @State var showParticipationAlert: Bool = false
    @State var clickedRoom: CarPoolRoom?
    
    @State var createToChatRoom: Bool = false
    @State var mapToChatRoom: Bool = false
    
    @EnvironmentObject var viewModel : MainViewModel
    @EnvironmentObject var appDelegate : AppDelegate
    @StateObject var realmManager = RealmManger()
    @State var favorites : [Place] = []
    @State var editingFocus: SearchField?
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.progress == .loading)) {
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
                    manager.requestWhenInUseAuthorization()
                    manager.startUpdatingLocation()
                    region.center = manager.location?.coordinate ?? region.center
                    
                }
                
                // SearchView(검색뷰) , 카풀 목록 보기 버튼
                VStack(spacing: 0) {
                    SearchView(
                        startPlaceName: $startPlaceName,
                        endPlaceName: $endPlaceName,
                        isExpanded: $isExpanded,
                        editingFocus: $editingFocus
                    ){ searchField in
                        // submit action
                        showModal = true
                        self.searchField = searchField
                        switch searchField {
                        case .start:
                            Task {
                                self.placeList = await viewModel.searchPlace(keyword: startPlaceName)
                            }
//                            viewModel.searchPlace(keyword: startPlaceName)
                        case .end:
                            Task {
                                self.placeList = await viewModel.searchPlace(keyword: endPlaceName)
                            }
//                            viewModel.searchPlace(keyword: endPlaceName)
                        }
                    }.padding(.horizontal, 12)
                    
                    .shadow(radius: 3, y:2)
                    ScrollView(.horizontal) {
                        LazyHStack(alignment: .center, spacing: 0) {
                            ForEach(favorites, id: \.self) { favorite in
                                FavoriteButton(favorite: favorite) {
                                    // 즐찾 버튼 클릭 action
                                    if let editingFocus = editingFocus {
                                        switch editingFocus {
                                        case .start:
                                            self.startPlace = favorite
                                            self.startPlaceName = favorite.place_name
                                            addPoint(favorite, true)
                                        case .end:
                                            self.endPlace = favorite
                                            self.endPlaceName = favorite.place_name
                                            self.isExpanded = true
                                            addPoint(favorite, false)
                                        }
                                    } else {
                                        self.endPlace = favorite
                                        self.endPlaceName = favorite.place_name
                                        self.isExpanded = true
                                        addPoint(favorite, false)
                                    }
                                    if let startPlace = startPlace {
                                        addPoint(startPlace, true)
                                    }
                                
                                }
                                .padding(.leading, 5)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .frame(height: 40)
                    .padding(.top, 4)
                    
                    
                    Spacer()
                    Button {
                        // 카풀 목록 보기
                        self.showBottomSheet.toggle()
                    } label: {
                        Text("카풀 목록 보기")
                            .font(.system(size: 13))
                            .foregroundColor(Color("main_blue"))
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(Color("white"))
                            .cornerRadius(35)
                            .overlay {
                                RoundedRectangle(cornerRadius: 35)
                                    .stroke().foregroundColor(Color("main_blue"))
                            }
                    }
                    .padding(.bottom, showMyRoomBox ? 9 : 104)
                    
                    if showMyRoomBox {
                        MyRoomBox(
                            room: $myRoom
                        ) {
                            self.mapToChatRoom = true
                        }
                            .padding(.bottom, 102)
                            .padding(.horizontal, 12)
                    }
                }
                .padding(.top, 60)
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
                            if let safeUser = viewModel.currentUser {
                                Task {
                                    let rooms = await viewModel.getAllRoom(genderOption: safeUser.gender)
                                    self.poolList = rooms
                                }
                            }
                        } label: {
                            Image("refresh")
                                .padding(.all, 13)
                                .background(Color("white"))
                                .clipShape(Circle())
                                .shadow(radius: 3, y: 5)
                                .padding(.trailing, 15)
                                .padding(.bottom, 11)
                        }
                        

                        ZStack(alignment: .topLeading) {
                            Color("white")
                            VStack(spacing: 0) {
                                HStack {
                                    Text("카풀 목록")
                                        .font(.system(size: 20))
                                        .foregroundColor(Color("black"))
                                        .fontWeight(.heavy)
                                        .padding(.leading, 22)
                                    Spacer()
                                    
                                    Button {
                                        // 방 생성 버튼 Action
                                        if myRoom != nil {
                                            showAlert = true
                                            alertMsg = "이미 참가 중인 카풀이 있습니다"
                                            return
                                        }
                                        createToChatRoom = true
                                    } label: {
                                        Image("plus")
                                            .padding(.all, 18)
                                    }
                                    .padding(.trailing, 4)
                                    
                                }
                                
                                if poolList.isEmpty {
                                    Image("character")
                                    Text("+버튼을 눌러\n첫번째 채팅방을 생성해보세요!")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size:16))
                                        .foregroundColor(Color("black"))
                                } else {
                                    ScrollView(.horizontal) {
                                        LazyHStack(alignment: .top ) {
                                            ForEach(poolList, id: \.self) { room in
                                                RoomItem(
                                                    room: room,
                                                    location: manager.location?.coordinate,
                                                    user: viewModel.currentUser
                                                ) { clickedRoom in
                                                    guard let safeUser = viewModel.currentUser else {
                                                        alertMsg = "알 수 없는 오류"
                                                        showAlert = true
                                                        return
                                                    }
                                                    if clickedRoom.participants.contains(safeUser.uid) {
                                                        // 내 방
                                                        self.mapToChatRoom = true
                                                    } else {
                                                        // 다른 방
                                                        if myRoom != nil {
                                                            showAlert = true
                                                            alertMsg = "이미 참가 중인 카풀이 있습니다"
                                                            return
                                                        } else {
                                                            showParticipationAlert = true
                                                            self.clickedRoom = clickedRoom
                                                        }
                                                    }
                                                }
                                                .padding(.leading, 10)
                                            }
                                        }
                                    }
                                }
                            }
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
                    .onAppear {
                        if let safeUser = viewModel.currentUser {
                            Task {
                                let rooms = await viewModel.getAllRoom(genderOption: safeUser.gender)
                                self.poolList = rooms
                            }
                        }
                    }
                }
                
                NavigationLink(isActive: $mapToChatRoom) {
                    if let safeMyRoom = myRoom {
                        ChatRoomView(
                            myRoom: .constant(safeMyRoom),
                            mapToChatRoom: $mapToChatRoom
                        ).navigationBarBackButtonHidden()
                            .environmentObject(self.viewModel)
                            .environmentObject(self.appDelegate)
                    }
                } label: {}
                NavigationLink(isActive: $createToChatRoom) {
                    CreateRoomView(
                        createToChatRoom: $createToChatRoom,
                        mapToChatRoom: $mapToChatRoom,
                        startPlace: startPlace,
                        endPlace: endPlace
                    ).navigationBarBackButtonHidden()
                        .environmentObject(self.viewModel)
                } label: {}
            }.edgesIgnoringSafeArea(.all)
                .sheet(isPresented: $showModal) {
                    SearchResultModal(documents: $placeList) { place in
                        if searchField == .start {
                            startPlace = place
                            startPlaceName = place.place_name
                            addPoint(place, true)
                        }
                        if searchField == .end {
                            endPlace = place
                            endPlaceName = place.place_name
                            addPoint(place, false)
                            if let startPlace = startPlace {
                                addPoint(startPlace, true)
                            }
                        }
                        showModal = false
                    }
                }
                .alert("시스템 메세지", isPresented: $showAlert) {
                    Button("확인", role: .destructive) {}
                } message: {
                    Text(alertMsg)
                }
                .alert("시스템 메세지", isPresented: $showParticipationAlert) {
                    HStack {
                        Button("취소", role: .cancel) {}
                        Button("확인", role: .destructive) {
                            // 채팅방 입장하기
                            guard let user = viewModel.currentUser else { return }
                            
                            if let clickedRoom = clickedRoom {
                                Task {
                                    let tokens = await viewModel.getParticipantsTokens(roomId: clickedRoom.roomId)
                                    viewModel.joinRoom(
                                        room: clickedRoom
                                    ) { result in
                                        switch result {
                                        case .success(_):
                                            Task {
                                                await viewModel.sendPushMessage(
                                                    chat: Chat(value: [
                                                        "roomId": clickedRoom.roomId,
                                                        "userId":user.uid,
                                                        "userName":user.name,
                                                        "msg":"\(user.name)님이 입장하셨습니다",
                                                        "messageType":CHAT_JOIN,
                                                        "sendSuccess":SEND_STATE_SUCCESS
                                                    ]),
                                                    receiveTokens: tokens
                                                )
                                                self.mapToChatRoom = true
                                            }

                                        case .failure(_):
                                            showAlert = true
                                            alertMsg = "채팅방 입장 실패"
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                } message: {
                    Text("채팅방에 참여하시겠습니까?")
                }
                .onChange(of: viewModel.myRoom, perform: { myRoom in
                    if let safeRoom = myRoom {
                        self.showMyRoomBox = true
                        self.myRoom = safeRoom
                    } else {
                        self.showMyRoomBox = false
                        self.myRoom = nil
                    }
                })
                .onAppear{
                    if let location = manager.location {
                        convertCLLocationToAddress(location: location)
                    }
                    
                    realmManager.getFavorites()
                    self.favorites = realmManager.favorites.map { $0.convertToPlace() }
                    
                    if let safeRoom = viewModel.myRoom {
                        self.showMyRoomBox = true
                        self.myRoom = safeRoom
                    } else {
                        self.showMyRoomBox = false
                        self.myRoom = nil
                    }
                }
                .onDisappear {
                    showBottomSheet = false
                }
        }
    }
    
    private func convertCLLocationToAddress(location: CLLocation) {
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if error != nil { return }
            guard let placemark = placemarks?.first else { return }
            let keyword = "\(placemark.country ?? "") \(placemark.locality ?? "") \(placemark.name ?? "")"
            Task {
                if let currentLocation = await viewModel.searchPlace(keyword: keyword).first {
                    startPlace = currentLocation
                    startPlaceName = currentLocation.place_name
                }
            }
        }
    }
    
    fileprivate func moveCamera() {
        let latDistance = abs(points[0].coordinate.latitude.distance(to: points[1].coordinate.latitude))
        let lonDistance = abs(points[0].coordinate.longitude.distance(to: points[1].coordinate.longitude))
        
        self.region.span = .init(latitudeDelta: latDistance * 2 , longitudeDelta: lonDistance * 2)
        
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
        MapView(showBottomSheet: .constant(true))
            .environmentObject(MainViewModel())
    }
}
