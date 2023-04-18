//
//  RegisterView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/15.
//

import SwiftUI

enum Gender {
    case male
    case female
    case none
}

enum RegisterField: Hashable {
    case password, passwordConfirm, name
}

struct RegisterView: View {
    var email: String
    // Navigation RootView 로 돌아가기 위한 Binding
    @Binding var comeBackToRootView: Bool
    
    // 단순 값 저장을 위한 State
    @State var gender : Gender = .none
    @State var name: String = ""
    @State var passwordConfirm: String = ""
    @State var password: String = ""
    @State var guideText: String = "비밀번호를 입력해주세요"
    
    // 다음 단계로 넘어가기 위한 State
    @State var isAgreePrivacyPolicy: Bool = false
    @State var passwordOk: Bool = false
    @State var passwordConfirmOk: Bool = false
    @State var nameOk: Bool = false
    @State var genderOk: Bool = false
    @State var nextCount: Int = 0
    
    // 회원가입 수행 관련 State
    @State var isSuccessJoin: Bool = false
    @State var isFailedJoin: Bool = false
    @State var alertMsg: String = ""
    
    // 키보드 입력 FocusState
    @FocusState private var focusField: RegisterField?
    @StateObject var viewModel = WelcomeViewModel()
    
    var body: some View {
        LoadingView(isShowing: .constant(viewModel.authResult == .loading)) {
            ZStack(alignment: .topLeading){
                Image("welcomeBg").resizable()
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("회원가입")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                        .fontWeight(.heavy)
                        .padding(.top, 157)
                        .padding(.leading, 21)
                    
                    ZStack(alignment: .bottom) {
                        Color(.white)
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                Group {
                                    Text("사용자 정보")
                                        .font(.system(size: 24))
                                        .fontWeight(.bold)
                                        .padding(.top, 27)
                                        .padding(.leading, 21)
                                    
                                    Text(isAgreePrivacyPolicy ? "안녕하세요 \(name)님,\n입력한 정보가 모두 맞나요?" : guideText)
                                        .font(.system(size: 15))
                                        .padding(.top, 5)
                                        .padding(.leading, 21)
                                }
                                if nameOk {
                                    HStack(spacing:0) {
                                        Text("개인정보처리방침")
                                            .font(.system(size: 14))
                                            .underline()
                                        Text("에 동의합니다")
                                            .font(.system(size: 14))
                                        Spacer()
                                        RoundedRectangle(cornerRadius: 1)
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(isAgreePrivacyPolicy ? Color("main_blue") : Color("d9d9d9"))
                                            .onTapGesture {
                                                isAgreePrivacyPolicy.toggle()
                                            }
                                    }.padding(.horizontal, 21)
                                        .padding(.top, 16)
                                }
                                
                                Group {
                                    if nameOk {
                                        Text("성별")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .fontWeight(.heavy)
                                            .padding(.top, 16)
                                            .padding(.leading, 21)
                                        
                                        HStack(spacing: 0) {
                                            CustomRadioButton(
                                                label: "남성",
                                                isSelected: radioButtonIsSelected(.male)
                                            ) {
                                                self.gender = .male
                                            }.frame(maxWidth: .infinity)
                                            CustomRadioButton(
                                                label: "여성",
                                                isSelected: radioButtonIsSelected(.female)
                                            ) {
                                                self.gender = .female
                                            }.frame(maxWidth: .infinity)
                                            CustomRadioButton(
                                                label: "선택 안함",
                                                isSelected: radioButtonIsSelected(.none)
                                            ) {
                                                self.gender = .none
                                            }.frame(maxWidth: .infinity)
                                        }.frame(maxWidth: .infinity)
                                            .padding(.top, 7)
                                        
                                        if self.gender == .none {
                                            Text("같은 성별 매칭에서 제외될 수 있어요")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color("667080"))
                                                .frame(maxWidth: .infinity, alignment: .trailing)
                                                .padding(.top, 3)
                                                .padding(.trailing, 20)
                                        }
                                    }
                                }
                                Group {
                                    if passwordConfirmOk {
                                        Text("이름")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .fontWeight(.heavy)
                                            .padding(.top, 5)
                                            .padding(.leading, 21)
                                        
                                        RoundedTextField(
                                            text: $name,
                                            isValid: .constant(true),
                                            placeHolder: "실명기재",
                                            type: .normal,
                                            verticalPadding: 8,
                                            horizontalPadding: 13
                                        ){
                                            // submit action
                                            if !name.isEmpty {
                                                nameOk = true
                                                focusField = nil
                                                guideText = "성별을 선택해주세요"
                                            }
                                        }.padding(.top, 6)
                                            .padding(.horizontal, 21)
                                            .focused($focusField, equals: .name)
                                    }
                                    
                                    if passwordOk {
                                        HStack(spacing:0){
                                            Text("비밀번호 확인")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .fontWeight(.heavy)
                                            if password != passwordConfirm {
                                                Text("비밀번호가 일치하지 않습니다")
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color("red"))
                                                    .padding(.leading, 5)
                                            }
                                        }.padding(.top, 15)
                                            .padding(.leading, 21)
                                        
                                        RoundedTextField(
                                            text: $passwordConfirm,
                                            isValid: .constant(password == passwordConfirm),
                                            placeHolder: "비밀번호 확인",
                                            type: .password,
                                            verticalPadding: 8,
                                            horizontalPadding: 13
                                        ){
                                            // submit action
                                            if password == passwordConfirm {
                                                passwordConfirmOk = true
                                                focusField = .name
                                                guideText = "이름(실명)을 입력해주세요"
                                            }
                                        }.padding(.top, 6)
                                            .padding(.horizontal, 21)
                                            .focused($focusField, equals: .passwordConfirm)
                                    }
                                    
                                    HStack(spacing:0){
                                        Text("비밀번호")
                                            .font(.system(size: 14))
                                            .foregroundColor(.black)
                                            .fontWeight(.heavy)
                                        Text("(영문 대/소문자,숫자,특수문자 포함 8~16자)")
                                            .font(.system(size: 10))
                                            .foregroundColor(Color("red"))
                                            .padding(.leading, 5)
                                    }.padding(.top, 15)
                                        .padding(.leading, 21)
                                    
                                    RoundedTextField(
                                        text: $password,
                                        isValid: .constant(password.validatePassword()),
                                        placeHolder: "비밀번호",
                                        type: .password,
                                        verticalPadding: 8,
                                        horizontalPadding: 13
                                    ){
                                        // submit action
                                        if password.validatePassword() {
                                            passwordOk = true
                                            focusField = .passwordConfirm
                                            guideText = "비밀번호를 확인해주세요"
                                        }
                                        
                                    }.padding(.top, 6)
                                        .padding(.horizontal, 21)
                                        .focused($focusField, equals: .password)
                                }
                                
                                Divider()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 500)
                                    .opacity(0)
                            }
                        }
                        
                        
                        
                        if password.validatePassword() && password == passwordConfirm && !name.isEmpty && isAgreePrivacyPolicy {
                            Button {
                                // 회원가입
                                var genderValue: String
                                switch gender {
                                case .none: genderValue = "none"
                                case .female: genderValue = "female"
                                case .male: genderValue = "male"
                                }
                                let user = User(
                                    uid: "",
                                    email: email,
                                    name: name,
                                    gender: genderValue
                                )
                                viewModel.createUser(email: email, password: password, newUser: user)
                            } label: {
                                Text("회원가입")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 16)
                                    .frame(maxWidth: .infinity)
                            }
                            .background(Color("main_blue"))
                            .cornerRadius(100)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 47)
                            .shadow(radius: 3, y:5)
                            .alert("회원가입 성공", isPresented: $isSuccessJoin) {
                                Button("확인", role: .cancel) {
                                    print("comeBackToRootView = false")
                                    comeBackToRootView = false
                                }
                            } message: {
                                Text(alertMsg)
                            }
                            .alert("회원가입 실패", isPresented: $isFailedJoin) {
                                Button("확인", role: .cancel) {}
                            } message: {
                                Text(alertMsg)
                            }
                        }
                    }
                    .cornerRadius(40)
                    .padding(.top, 18)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea(.keyboard)
            .onAppear {
                focusField = .password
                
            }
            .onChange(of: viewModel.authResult) { newValue in
                switch newValue {
                case .failure(_):
                    isFailedJoin = true
                    alertMsg = "회원정보를 확인해주세요"
                case .success(let msg):
                    isSuccessJoin = true
                    alertMsg = msg
                default:
                    break
                }
            }
            
        }
    }
    
    private func radioButtonIsSelected(_ gender: Gender) -> Bool {
        self.gender == gender ? true : false
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(email: "", comeBackToRootView: .constant(false))
    }
}
