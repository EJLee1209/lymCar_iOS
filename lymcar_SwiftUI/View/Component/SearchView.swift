//
//  SearchView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI

struct SearchView: View {
    @State private var startPlaceName: String = ""
    @State private var endPlaceName: String = ""
    @State private var isExpanded: Bool = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            if isExpanded {
                VStack(spacing:9) {
                    RoundedTextField(text: $startPlaceName, isValid: .constant(true), placeHolder: "출발지", type: .normal)
                    RoundedTextField(text: $startPlaceName, isValid: .constant(true), placeHolder: "목적지", type: .normal)
                }
            }
            else {
                TextField("목적지", text: $endPlaceName)
            }
            
            Button {
                // 검색 action
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                Image("search")
                    .padding(.all, 11)
            }
            .padding([.leading,.trailing], 10)
            
        }
        .padding(10)
        .background(Color("white"))
        .cornerRadius(15)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
