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
    static func getCurrentDateTime() -> String {
        let now = "\(Date())"
        let dateTime = now.split(separator: " ")
        let formattedDateTime = "\(dateTime[0])T\(dateTime[1])"
        return formattedDateTime
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
    
}

