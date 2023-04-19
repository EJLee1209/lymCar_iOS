//
//  RoundedCornerShape.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import Foundation
import SwiftUI

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
