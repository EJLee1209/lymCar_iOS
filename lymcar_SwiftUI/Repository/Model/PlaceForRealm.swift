//
//  PlaceForRealm.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/24.
//

import Foundation
import RealmSwift

class PlaceForRealm: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var place_name: String = ""
    @Persisted var address_name: String = ""
    @Persisted var road_address_name: String = ""
    @Persisted var x: Double = 0
    @Persisted var y: Double = 0
    
    static var mock : [PlaceForRealm] = [
        PlaceForRealm(value: [
            "place_name" : "춘천시외버스터미널",
            "address_name" : "강원 춘천시 온의동 511",
            "road_address_name" : "강원 춘천시 경춘로 2341",
            "x" : Double(127.718623878218) ,
            "y" : Double(37.8631849670621)
        ] as [String : Any]),
        PlaceForRealm(value: [
            "place_name" : "춘천역 경춘선",
            "address_name" : "강원 춘천시 근화동 190",
            "road_address_name" : "강원 춘천시 공지로 591",
            "x" : Double(127.716698593345) ,
            "y" : Double(37.884512737384)
        ] as [String : Any]),
        PlaceForRealm(value: [
            "place_name" : "한림대학교",
            "address_name" : "강원 춘천시 후평동 671",
            "road_address_name" : "강원 춘천시 한림대학길 1",
            "x" : Double(127.7381263186237) ,
            "y" : Double(37.88728582472663)
        ] as [String : Any]),
    ]
}

extension PlaceForRealm {
    func convertToPlace() -> Place {
        return Place(
                place_name: self.place_name,
                address_name: self.address_name,
                road_address_name: self.road_address_name,
                x: String(self.x),
                y: String(self.y)
            )
    }
}
