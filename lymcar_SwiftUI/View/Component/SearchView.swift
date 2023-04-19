//
//  SearchView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/19.
//

import SwiftUI

enum SearchField {
    case start, end
}

struct SearchView: View {
    @Binding var startPlaceName: String
    @Binding var endPlaceName: String
    var submitAction: (SearchField) -> Void
    @State private var isExpanded: Bool = false
    @FocusState var focus: SearchField?
    
    var body: some View {
        HStack(spacing: 0) {
            
            if isExpanded {
                VStack(spacing:9) {
                    RoundedTextField(text: $startPlaceName, isValid: .constant(true), placeHolder: "출발지", type: .normal, submitLabel: .search) {
                        // submit action
                        submitAction(.start)
                    }
                    .focused($focus, equals: .start)
                    RoundedTextField(text: $endPlaceName, isValid: .constant(true), placeHolder: "목적지", type: .normal, submitLabel: .search) {
                        // submit action
                        submitAction(.end)
                    }
                    .focused($focus, equals: .end)
                }
            }
            else {
                TextField("", text: $endPlaceName)
                    .submitLabel(.search)
                    .onSubmit {
                        submitAction(.end)
                        if !isExpanded {
                            isExpanded.toggle()
                        }
                    }
                    .focused($focus, equals: .end)
                    .placeholder(when: endPlaceName.isEmpty) {
                        Text("목적지")
                            .font(.system(size: 15))
                            .foregroundColor(Color("d9d9d9"))
                    }
            }
            
            Button {
                // 검색 action
                withAnimation {
                    if !isExpanded {
                        isExpanded.toggle()
                    }
                    focus = nil
                }
            } label: {
                Image("search")
                    .padding(.all, 11)
            }
            .padding(.leading, 10)
            
        }
        .padding(10)
        .background(Color("white"))
        .cornerRadius(20)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(startPlaceName: .constant(""), endPlaceName: .constant("")) { searchField in
            
        }
    }
}
