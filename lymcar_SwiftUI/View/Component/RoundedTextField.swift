//
//  RoundedTextField.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI

enum TextFieldType {
    case normal
    case password
}

struct RoundedTextField: View {
    @Binding var text: String
    @Binding var isValid: Bool
    @State var isSecured: Bool = true
    var placeHolder: String
    var type: TextFieldType
    var verticalPadding: CGFloat = 16
    var horizontalPadding: CGFloat = 10
    var submitLabel: SubmitLabel = .done
    var submitAction: () -> Void = {}
    
    var body: some View {
        if type == .normal {
            TextField(placeHolder, text: $text)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .background(Color("f5f5f5"))
                .cornerRadius(10)
                .submitLabel(submitLabel)
                .onSubmit {
                    submitAction()
                }
            
        }
        else {
            ZStack(alignment: .trailing) {
                Group {
                    if isSecured {
                        SecureField(placeHolder, text: $text)
                            .submitLabel(submitLabel)
                            .onSubmit {
                                submitAction()
                            }
                    } else {
                        TextField(placeHolder, text: $text)
                            .submitLabel(submitLabel)
                            .onSubmit {
                                submitAction()
                            }
                    }
                }.padding(.trailing, 32)
                
                Button {
                    isSecured.toggle()
                } label: {
                    Image(systemName: self.isSecured ? "eye.slash" : "eye")
                        .tint(.gray)
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(Color("f5f5f5"))
            .cornerRadius(10)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: isValid ? 0 : 1)
                    .foregroundColor(Color("red"))
            }
        }
    }
}

struct RoundedTextField_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTextField(text: .constant(""), isValid: .constant(true), placeHolder: "비밀번호", type: .normal)
    }
}
