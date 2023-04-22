//
//  MultiPickerView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/21.
//

import SwiftUI

struct MultiPicker: View  {

    typealias Label = String
    typealias Entry = String

    let data: [ (Label, [Entry]) ]
    @Binding var selection: [Entry]

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing:0) {
                ForEach(0..<self.data.count) { column in
                    Picker(self.data[column].0, selection: self.$selection[column]) {
                        ForEach(0..<self.data[column].1.count) { row in
                            Text(verbatim: self.data[column].1[row])
                            .tag(self.data[column].1[row])
                            .foregroundColor(Color("black"))
                            .font(.system(size: 20))
                            .bold()
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    .frame(height: 120)
                    .frame(width: geometry.size.width / CGFloat(self.data.count), height: geometry.size.height)
                    .clipped()
                }
            }
        }
    }
}

struct MultiPickerView_Previews: PreviewProvider {
    static var previews: some View {
        MultiPicker(
            data: [
                ("todayOrTomorrow", Array(arrayLiteral: "오늘", "내일").map { $0 }),
                ("pmOrAm", Array(arrayLiteral: "오전", "오후").map { $0 }),
                ("hour", Array(0...12).map { "\($0)" }),
                ("minute", Array(stride(from: 0, to: 60, by: 5)).map { "\($0)" })
            ],
            selection: .constant(
                ["오늘", "오후", "11", "30"]
            )
        )
    }
}
