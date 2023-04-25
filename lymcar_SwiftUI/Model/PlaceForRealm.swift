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