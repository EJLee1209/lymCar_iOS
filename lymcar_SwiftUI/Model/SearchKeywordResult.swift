//
//  SearchKeywordResult.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

//data class ResultSearchKeyword(
//    var documents: List<Place>
//)
//
//@Parcelize
//@Entity(tableName = "favorite")
//data class Place(
//    val place_name: String = "",
//    val address_name: String = "",
//    var road_address_name: String = "",
//    val x: Double = 0.0, // longitude
//    val y: Double = 0.0, // latitude
//    @PrimaryKey(autoGenerate = true)
//    val id: Long = 0
//) : java.io.Serializable, Parcelable


import Foundation

struct SearchKeywordResult: Codable {
    var documents: [Place]
}

struct Place: Codable, Hashable {
    var place_name: String = ""
    var address_name: String = ""
    var road_address_name: String = ""
    var x: String = ""
    var y: String = ""
}

extension Place: Equatable {
    static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.place_name == rhs.place_name
    }
}
