//
//  MapView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI
import MapKit

struct MapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.88371, longitude: 127.73947),
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    )
    @State var startPlaceName: String = ""
    @State var endPlaceName: String = ""
    @State var showModal: Bool = false
    @State var placeList = [Place]()
    @State var startPlace: Place?
    @State var endPlace: Place?
    @State var searchField: SearchField?
    @StateObject var viewModel = MainViewModel()
    
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.searchResult == .loading)) {
            ZStack(alignment: .top) {
                Map(coordinateRegion: $region, showsUserLocation: true)
                    .onAppear {
                        let manager = CLLocationManager()
                        manager.requestWhenInUseAuthorization()
                        manager.startUpdatingLocation()
                }
                
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
                }
                .padding(.top, 60)
                .padding(.horizontal, 12)
                
                
            }.edgesIgnoringSafeArea(.all)
                .sheet(isPresented: $showModal) {
                    SearchResultModal(documents: $placeList) { place in
                        if searchField == .start {
                            startPlace = place
                            startPlaceName = place.road_address_name
                        }
                        if searchField == .end {
                            endPlace = place
                            endPlaceName = place.road_address_name
                        }
                        showModal = false
                    }
                }
                .onChange(of: viewModel.searchResult) { newValue in
                    switch newValue {
                    case .success(let result):
                        placeList = result.documents
                        print("\(placeList)")
                    case .failure(let msg):
                        print(msg)
                    default:
                        break
                    }
                }
        }
        
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
