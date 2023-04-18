//
//  GeometryGetter.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/16.
//

import SwiftUI

struct GeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        GeometryReader { geometry in
            Group { () -> AnyView in
                DispatchQueue.main.async {
                    self.rect = geometry.frame(in: .global)
                }

                return AnyView(Color.clear)
            }
        }
    }
}

struct GeometryGetter_Previews: PreviewProvider {
    static var previews: some View {
        GeometryGetter(rect: .constant(.null))
    }
}
