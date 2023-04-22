//
//  TestPickerView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/22.
//

import SwiftUI

struct TestPickerView: View {
    var data = Array(0...20).map { "\($0)" }
        @State private var selected = 0

        
        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: UIScreen.main.bounds.size.width-18, height: 32)
                    .foregroundColor(.green)
                
                Picker("", selection: $selected) {
                    ForEach(0 ..< data.count) {
                        Text(data[$0])
                    }
                }.pickerStyle(.wheel)
            }
        }
}

struct TestPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TestPickerView()
    }
}
