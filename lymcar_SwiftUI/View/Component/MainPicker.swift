//
//  MainPicker.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/22.
//

import SwiftUI

import SwiftUI

struct ContentView: View {

    @State private var selections: [Int] = [1, 1, 10, 50]

    var body: some View {
        MainPicker(pickerSelections: self.$selections)
    }
}

struct MainPicker: View {
    
    @Binding var pickerSelections: [Int]
    
    private let data: [[String]] = [
        Array(arrayLiteral: "내일", "오늘"),
        Array(arrayLiteral: "오전", "오후"),
        Array(0...12).map { "\($0 < 10 ? "0" : "")" + "\($0)" },
        Array(stride(from: 0, to: 60, by: 5)).map { "\($0 < 10 ? "0" : "")" + "\($0)" }
    ]
    
    var body: some View {
        HStack{
            PickerView(data: data, selections: self.$pickerSelections)
        }
    }
}

struct PickerView: UIViewRepresentable {
    var data: [[String]]
    @Binding var selections: [Int]

    //makeCoordinator()
    func makeCoordinator() -> PickerView.Coordinator {
        Coordinator(self)
    }

    //makeUIView(context:)
    func makeUIView(context: UIViewRepresentableContext<PickerView>) -> UIPickerView {
        let picker = UIPickerView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        
        picker.superview?.frame = CGRect(x: 0, y: 0, width: 100, height: 100) //doesnt work
        picker.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return picker
    }

    //updateUIView(_:context:)
    func updateUIView(_ view: UIPickerView, context: UIViewRepresentableContext<PickerView>) {
        for i in 0...(self.selections.count - 1) {
            if(context.coordinator.initialSelection[i] != self.selections[i]){
                view.selectRow(self.selections[i], inComponent: i, animated: false)
                context.coordinator.initialSelection[i] = self.selections[i]
            }
        }
    }

    class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: PickerView
        var initialSelection = [-1, -1, -1, -1]
        
        //init(_:)
        init(_ pickerView: PickerView) {
            self.parent = pickerView
        }

        //numberOfComponents(in:)
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return self.parent.data.count
        }

        //pickerView(_:numberOfRowsInComponent:)
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return self.parent.data[component].count
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 50
        }

        //pickerView(_:titleForRow:forComponent:)
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return self.parent.data[component][row]
        }

        //pickerView(_:didSelectRow:inComponent:)
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selections[component] = row
        }
    }
}

struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
