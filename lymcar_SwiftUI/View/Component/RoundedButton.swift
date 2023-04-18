//
//  RoundedButton.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

struct RoundedButton: View {
    var label: String
    var buttonColor: String
    var labelColor: String
    
    var body: some View {
        Text(label)
            .foregroundColor(Color(labelColor))
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(Color(buttonColor))
            .cornerRadius(100)
    }
}

struct RoundedButton_Previews: PreviewProvider {
    static var previews: some View {
        RoundedButton(label: "로그인", buttonColor: "main_blue", labelColor: "white")
    }
}
