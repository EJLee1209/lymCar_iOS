//
//  CreateRoomView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/21.
//

import SwiftUI

struct CreateRoomView: View {
    @Binding var createToChatRoom: Bool
    @Binding var mapToChatRoom: Bool
    @State var startPlace: Place?
    @State var endPlace: Place?
    
    @State var startPlaceName: String = ""
    @State var endPlaceName: String = ""
    @State var userCount: Int = 4
    
    @State private var selections: [Int] = [1,1, 11, 0]
    @State var genderOption: Bool = false
    @State var showAlert: Bool = false
    @State var alertMsg: String = ""
    @State var showModal: Bool = false
    @State var placeList = [Place]()
    @State var searchField: SearchField?
    @State var isCreated: Bool = false
    
    @EnvironmentObject var viewModel: MainViewModel
    
    @Environment(\.dismiss) var dismiss
    @GestureState private var dragOffset = CGSize.zero
    
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.progress == .loading)) {
            ZStack(alignment: .bottom) {
                Color("main_blue")
                Color("white")
                    .roundedCorner(30, corners: [.topLeft, .topRight])
                    .padding(.top, 120)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Button {
                            // 뒤로가기
                            createToChatRoom.toggle()
                        } label: {
                            Image(systemName: "chevron.left")
                                .padding(10)
                                .font(.system(size: 25))
                                .foregroundColor(Color("white"))
                        }
                        Spacer()
                        Text("방 만들기")
                            .padding(.trailing, 25)
                            .font(.system(size:20))
                            .bold()
                            .foregroundColor(Color("white"))
                        Spacer()
                    }
                    .padding(.horizontal, 21)
                    
                    SearchView(
                        startPlaceName : $startPlaceName,
                        endPlaceName: $endPlaceName,
                        isExpanded: .constant(true),
                        editingFocus: .constant(nil),
                        buttonImage: "change",
                        submitAction: { searchField in
                            showModal = true
                            self.searchField = searchField
                            switch searchField {
                            case .start:
                                Task {
                                    self.placeList = await viewModel.searchPlace(keyword: startPlaceName)
                                }
                            case .end:
                                Task {
                                    self.placeList = await viewModel.searchPlace(keyword: endPlaceName)
                                }
                            }
                        }) {
                            // change button click action
                            let tmp = startPlaceName
                            startPlaceName = endPlaceName
                            endPlaceName = tmp
                            
                            let tmp2 = startPlace
                            startPlace = endPlace
                            endPlace = tmp2
                        }
                        .padding([.horizontal, .top], 12)
                        .shadow(radius: 5)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("최대 인원수")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .bold()
                            HStack(alignment: .center, spacing: 48) {
                                Spacer()
                                Button {
                                    if userCount > 2 {
                                        userCount -= 1
                                    }
                                } label: {
                                    Image("divide-circle")
                                }
                                Text("\(userCount)")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color("black"))
                                    .fontWeight(.heavy)
                                Button {
                                    if userCount < 4 {
                                        userCount += 1
                                    }
                                } label: {
                                    Image("plus-circle")
                                }
                                Spacer()
                            }
                            .padding(.top, 10)
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 40, height: 5)
                                .foregroundColor(Color("main_blue"))
                                .frame(maxWidth: .infinity)
                            
                            Text("출발시간")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .bold()
                                .padding(.top, 25)
                            MainPicker(pickerSelections: $selections)
                                .frame(maxWidth: .infinity)
                            
                            Text("탑승옵션")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .bold()
                            HStack(spacing: 0) {
                                Text("동성끼리 탑승하기")
                                    .font(.system(size: 15))
                                    .foregroundColor(Color("black"))
                                Spacer()
                                RoundedRectangle(cornerRadius: 1)
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(genderOption ? Color("main_blue") : Color("d9d9d9"))
                                    .onTapGesture {
                                        genderOption.toggle()
                                    }
                            }.padding(.top, 13)
                            if !genderOption {
                                Text("선택하지 않을 경우 성별 상관 없이 배차됩니다.")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color("red"))
                                    .padding(.top, 6)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 36)
                        .padding(.bottom, 100)
                    }
                }.padding(.top, 50)
                
                Button {
                    // 방 만들기 action
                    if startPlace == nil || endPlace == nil {
                        // 출발지 목적지 설정 안함
                        showAlert = true
                        alertMsg = "출발지와 목적지를 설정해주세요"
                        return
                    }
                    if startPlace == endPlace {
                        showAlert = true
                        alertMsg = "출발지와 목적지가 같습니다."
                        return
                    }
                    let todayOrTommorow: String
                    if selections[0] == 0 {
                        todayOrTommorow = "내일"
                    } else {
                        todayOrTommorow = "오늘"
                    }
                    
                    let departureTime = "\(todayOrTommorow.getDateFromTodayOrTommorow())T\(Utils.get24Hour(hour: Int(selections[2]), pmOrAm: selections[1])):\(selections[3] * 5)"
                    
                    guard let departureTimeForValidDate = departureTime.replacingOccurrences(of: "T", with: " ").toDate() else {
                        return
                    }
                    
                    let isFuture = Utils.getLocalizedDate().isFuture(fromDate: departureTimeForValidDate)
                    if !isFuture {
                        showAlert = true
                        alertMsg = "설정하신 출발시간이 이미 지났습니다\n현재시간:\(Utils.getLocalizedDate())\n설정한 시간:\(departureTime)"
                        return
                    }
                
                    let startPlaceForDB = PlaceForDB(
                        place_name: startPlace!.place_name,
                        address_name: startPlace!.address_name,
                        road_address_name: startPlace!.road_address_name,
                        x: Double(startPlace!.x)!,
                        y: Double(startPlace!.y)!
                    )
                    let endPlaceForDB = PlaceForDB(
                        place_name: endPlace!.place_name,
                        address_name: endPlace!.address_name,
                        road_address_name: endPlace!.road_address_name,
                        x: Double(endPlace!.x)!,
                        y: Double(endPlace!.y)!
                    )
                    
                    let room = CarPoolRoom(
                        userMaxCount: userCount,
                        startPlace: startPlaceForDB,
                        endPlace: endPlaceForDB,
                        departureTime: departureTime,
                        created: Utils.getCurrentDateTime(),
                        genderOption: self.genderOption ? viewModel.currentUser?.gender ?? Constants.GENDER_OPTION_NONE : Constants.GENDER_OPTION_NONE
                    )
                    
                    Task {
                        let result = await viewModel.createRoom(room: room)
                        if result {
                            createToChatRoom = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                mapToChatRoom = true
                            }
                        } else {
                            showAlert = true
                            alertMsg = "알 수 없는 오류\n잠시 후 다시 시도해주세요"
                        }
                    }
                    
                } label: {
                    RoundedButton(
                        label: "방 만들기",
                        buttonColor: "main_blue",
                        labelColor: "white"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 47)
                .alert("방 생성 실패", isPresented: $showAlert) {
                    Button("확인", role: .cancel) {}
                } message: {
                    Text(alertMsg)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                startPlaceName = startPlace?.place_name ?? ""
                endPlaceName = endPlace?.place_name ?? ""
            }
            .sheet(isPresented: $showModal) {
                SearchResultModal(documents: $placeList) { place in
                    if searchField == .start {
                        self.startPlace = place
                        startPlaceName = place.place_name
                    }
                    if searchField == .end {
                        self.endPlace = place
                        endPlaceName = place.place_name
                    }
                    showModal = false
                }
            }
            .gesture(DragGesture().updating($dragOffset, body: { value, state, transaction in
                if value.startLocation.x < 20 && value.translation.width > 100 {
                    self.createToChatRoom = false
                }
            }))
        }
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView(createToChatRoom: .constant(false), mapToChatRoom: .constant(false))
            .environmentObject(MainViewModel())
    }
}
