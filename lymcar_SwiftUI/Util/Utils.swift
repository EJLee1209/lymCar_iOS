//
//  Utils.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/18.
//

import Foundation
import UIKit

class Utils {
    static func getDeviceUUID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    static func getLocalizedDate() -> Date {
        let today = Date()
        let timezone = TimeZone.autoupdatingCurrent
        let secondsFromGMT = timezone.secondsFromGMT(for: today)
        let localizedDate = today.addingTimeInterval(TimeInterval(secondsFromGMT))
        return localizedDate
    }
    
    static func getCurrentDateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = dateFormatter.string(from: Date())
        
        return currentDate.replacingOccurrences(of: " ", with: "T")
    }
    
    static func get24Hour(hour: Int, pmOrAm: String) -> Int {
        if pmOrAm == "오전" {
            return hour
        } else {
            if hour >= 1 && hour <= 11 {
                return hour + 12
            }
            else {
                return hour
            }
        }
    }
    // "2023-04-21T11:11"
    static func getPrettyDateTime(dateTime: String) -> String {
        var prettyDateTime = ""
        guard let realDateTime = dateTime.replacingOccurrences(of: "T", with: " ").toDate() else {
            return dateTime
        }
        var times = dateTime.split(separator: "T")[1].split(separator: ":")
        var hour = Int(times[0])!
        let min = times[1]
        
        let today = Date()
        let timezone = TimeZone.autoupdatingCurrent
        let secondsFromGMT = timezone.secondsFromGMT(for: today)
        let localizedDateTime = realDateTime.addingTimeInterval(TimeInterval(-secondsFromGMT))
        if Calendar.current.isDateInToday(localizedDateTime) {
            prettyDateTime += "오늘"
        } else if Calendar.current.isDateInTomorrow(localizedDateTime) {
            prettyDateTime += "내일"
        } else {
            return dateTime
        }
        
        if hour >= 12 {
            prettyDateTime += " 오후"
            if hour > 12 {
                hour -= 12
            }
        } else {
            prettyDateTime += " 오전"
        }
        prettyDateTime += (" \(hour):\(min)")
        
        return prettyDateTime
    }
    
    
    static func getNowDateTime24() -> String {
        // [date 객체 사용해 현재 날짜 및 시간 24시간 형태 출력 실시]
        let nowDate = Date() // 현재의 Date 날짜 및 시간
        let dateFormatter = DateFormatter() // Date 포맷 객체 선언
        dateFormatter.locale = Locale(identifier: "ko") // 한국 지정
        
        dateFormatter.dateFormat = "yyyy.MM.dd kk:mm:ss E요일" // Date 포맷 타입 지정
        let date_string = dateFormatter.string(from: nowDate) // 포맷된 형식 문자열로 반환
        
        return date_string
    }
    
}

