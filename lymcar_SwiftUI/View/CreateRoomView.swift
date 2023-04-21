//
//  CreateRoomView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/21.
//

import SwiftUI

struct CreateRoomView: View {
    @Binding var showCreateRoomView: Bool
    var startPlace: Place?
    var endPlace: Place?
    
    @State var startPlaceName: String = ""
    @State var endPlaceName: String = ""
    @State var userCount: Int = 2
    
    @State var data: [(String, [String])] = [
        ("todayOrTomorrow", Array(arrayLiteral: "오늘", "내일").map { $0 }),
        ("pmOrAm", Array(arrayLiteral: "오전", "오후").map { $0 }),
        ("hour", Array(0...12).map { "\($0)" }),
        ("minute", Array(stride(from: 0, to: 60, by: 5)).map { "\($0)" })
    ]
    @State var selection: [String] = ["오늘", "오후", 11, 30].map { "\($0)" }
    @State var genderOption: Bool = false
    @State var showAlert: Bool = false
    @State var alertMsg: String = ""
    @StateObject var viewModel = MainViewModel()
    
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
                            showCreateRoomView.toggle()
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
                        buttonImage: "change",
                        submitAction: { searchField in
                            
                        }) {
                            // change button click action
                            let tmp = startPlaceName
                            startPlaceName = endPlaceName
                            endPlaceName = tmp
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
                            MultiPicker(data: data, selection: $selection).frame(height: 300)
                                .frame(height: 40)
                                .padding(.top, 50)
                            
                            Text("탑승옵션")
                                .font(.system(size: 15))
                                .foregroundColor(Color("black"))
                                .bold()
                                .padding(.top, 80)
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
                    guard let departureTimeForValidDate = "\(selection[0].getDateFromTodayOrTommorow()) \(Utils.get24Hour(hour: Int(selection[2])!, pmOrAm: selection[1])):\(selection[3])".toDate() else {
                        return
                    }
                    let isFuture = Date().isFuture(fromDate: departureTimeForValidDate)
                    if !isFuture {
                        showAlert = true
                        alertMsg = "설정하신 출발시간이 이미 지났습니다\n현재 시간 : \(Date())"
                    }
                    let departureTime = "\(selection[0].getDateFromTodayOrTommorow())T\(Utils.get24Hour(hour: Int(selection[2])!, pmOrAm: selection[1])):\(selection[3])"
                    
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
                        genderOption: Constants.GENDER_OPTION_MALE
                    )
                    print("생성할 방 : \(room)")
                    
                    viewModel.createRoom(
                        room: room
                    ) { result in
                        switch result {
                        case .success(let carPoolRoom):
                            print(carPoolRoom)
                            showCreateRoomView.toggle()
                        case .failure(_):
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
                    HStack {
                        Button("확인", role: .cancel) {}
                    }
                } message: {
                    Text(alertMsg)
                }
                

            }
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                startPlaceName = startPlace?.place_name ?? ""
                endPlaceName = endPlace?.place_name ?? ""
            }
        }
    }
}

struct CreateRoomView_Previews: PreviewProvider {
    static var previews: some View {
        CreateRoomView(showCreateRoomView: .constant(false))
    }
}
