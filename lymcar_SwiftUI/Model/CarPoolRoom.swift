//
//  CarPoolRoom.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/20.
//

import Foundation

struct CarPoolRoom: Codable {
    var roomId: String = "" // 방 고유번호
    var participants: [String] = [String]() // 참여자들의 uid
    var userMaxCount: Int = 4 // 제한 인원
    var userCount: Int = 1 // 현재 참여 유저 수
    var startPlace: PlaceForDB = PlaceForDB() // 출발지
    var endPlace: PlaceForDB = PlaceForDB() // 목적지
    var departureTime: String = "" // 출발 시간
    var created: String = "" // 방 생성 시간
    var genderOption: String = "" // 탑승 옵션(남자/여자/상관없음)
    var closed: Bool = false // 방 마감 여부
    
    var dictionary: [String: Any] {
        return [
            "roomId" : roomId,
            "participants" : participants,
            "userMaxCount" : userMaxCount,
            "userCount" : userCount,
            "startPlace" : startPlace.dictionary,
            "endPlace" : endPlace.dictionary,
            "departureTime" : departureTime,
            "created" : created,
            "genderOption" : genderOption,
            "closed" : closed,
        ]
    }
}



