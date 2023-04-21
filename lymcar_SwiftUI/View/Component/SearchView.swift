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
    @Binding var isExpanded: Bool
    
    var buttonImage: String = "search"
    var submitAction: (SearchField) -> Void
    var buttonClickAction: () -> Void = {}
    
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
                
                buttonClickAction()
            } label: {
                Image(buttonImage)
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
        SearchView(startPlaceName: .constant("한림대학교"), endPlaceName: .constant("한림대학교"), isExpanded: .constant(true)) { _ in
            
        }
    }
}
