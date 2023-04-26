//
//  infoView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/26.
//

import SwiftUI

struct InfoView: View {
    var label: String = "이름"
    var text: String = "곽도철"
    
    init(_ label: String, _ text: String) {
        self.label = label
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(Color("667080"))
                .padding(.leading, 10)
            HStack {
                Text(text)
                    .font(.system(size: 16))
                    .foregroundColor(Color("black"))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
            .overlay {
                RoundedCornerShape(radius:10)
                    .stroke(lineWidth: 1)
                    .foregroundColor(Color("d9d9d9"))
                
            }
        }
        
    }
}

struct infoView_Previews: PreviewProvider {
    static var previews: some View {
        InfoView("이름", "곽도철")
    }
}
