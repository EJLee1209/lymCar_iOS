//
//  lymcar++Bundle.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/17.
//

import Foundation

extension Bundle {
    var baseUrl: String {
        guard let file = self.path(forResource: "serverInfo", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["BASE_URL"] as? String else { fatalError("serverInfo.plist에 BASE_URL을 설정해주세요") }
        return key
    }
}
