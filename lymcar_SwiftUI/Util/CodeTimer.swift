//
//  Timer.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import Foundation

class CodeTimer: ObservableObject {
    @Published var time: Int = 300
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.time -= 1
        }
    }
}
