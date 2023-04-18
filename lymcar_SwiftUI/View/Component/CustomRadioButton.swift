//
//  CustomRadioButton.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/15.
//

import SwiftUI

struct CustomRadioButton: View {
    var label: String
    var isSelected: Bool = false
    var buttonAction: () -> Void
    
    var body: some View {
        Button {
            buttonAction()
        } label: {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .white : .black)
                .padding(.vertical, 11)
                .frame(width: 91)
        }
        .background(Color(isSelected ? "main_blue" : "white"))
        .cornerRadius(45)
        .overlay {
            RoundedRectangle(cornerRadius: 45)
                .stroke()
                .foregroundColor(Color("main_blue"))
        }
    }
}

struct CustomRadioButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomRadioButton(label: "남성") {
            
        }
    }
}
