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
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
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
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
