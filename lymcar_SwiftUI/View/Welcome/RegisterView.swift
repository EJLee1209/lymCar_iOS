//
//  RegisterView.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/15.
//
import SwiftUI
import ComposableArchitecture

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
    @Binding var goToRootView: Bool
    
    @StateObject var keyboard: KeyboardObserver = KeyboardObserver()
    // 키보드 입력 FocusState
    @FocusState private var focusField: RegisterField?
    let store: StoreOf<RegisterFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            LoadingView(isShowing: .constant(viewStore.isLoading)) {
                ZStack(alignment: .topLeading){
                    Image("welcomeBg").resizable()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("회원가입")
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                            .padding(.top, keyboard.isShowing ? 100 : 157)
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
                                        
                                        Text(viewStore.guideText)
                                            .font(.system(size: 15))
                                            .padding(.top, 5)
                                            .padding(.leading, 21)
                                    }
                                    if viewStore.nameOk {
                                        HStack(spacing:0) {
                                            Text("개인정보처리방침")
                                                .font(.system(size: 14))
                                                .underline()
                                            Text("에 동의합니다")
                                                .font(.system(size: 14))
                                            Spacer()
                                            RoundedRectangle(cornerRadius: 1)
                                                .frame(width: 20, height: 20)
                                                .foregroundColor(viewStore.isAgreePrivacyPolicy ? Color("main_blue") : Color("d9d9d9"))
                                                .onTapGesture {
                                                    viewStore.send(.isAgreePrivacyPolicyChanged)
                                                }
                                        }.padding(.horizontal, 21)
                                            .padding(.top, 16)
                                    }
                                    
                                    Group {
                                        if viewStore.nameOk {
                                            Text("성별")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .fontWeight(.heavy)
                                                .padding(.top, 16)
                                                .padding(.leading, 21)
                                            
                                            HStack(spacing: 0) {
                                                CustomRadioButton(
                                                    label: "남성",
                                                    isSelected: viewStore.gender == .male
                                                ) {
                                                    viewStore.send(.genderChanged(.male))
                                                }.frame(maxWidth: .infinity)
                                                CustomRadioButton(
                                                    label: "여성",
                                                    isSelected: viewStore.gender == .female
                                                ) {
                                                    viewStore.send(.genderChanged(.female))
                                                }.frame(maxWidth: .infinity)
                                                CustomRadioButton(
                                                    label: "선택 안함",
                                                    isSelected: viewStore.gender == .none
                                                ) {
                                                    viewStore.send(.genderChanged(.none))
                                                }.frame(maxWidth: .infinity)
                                            }.frame(maxWidth: .infinity)
                                                .padding(.top, 7)
                                            
                                            if viewStore.gender == .none {
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
                                        if viewStore.passwordConfirmOk {
                                            Text("이름")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                                .fontWeight(.heavy)
                                                .padding(.top, 5)
                                                .padding(.leading, 21)
                                            
                                            RoundedTextField(
                                                text: Binding(
                                                    get: { viewStore.name },
                                                    set: {
                                                        viewStore.send(.nameChanged($0))
                                                    }
                                                ),
                                                isValid: .constant(true),
                                                placeHolder: "실명기재",
                                                type: .normal,
                                                verticalPadding: 8,
                                                horizontalPadding: 13
                                            ){
                                                // submit action
                                                viewStore.send(.submitName)
                                            }.padding(.top, 6)
                                                .padding(.horizontal, 21)
                                                .focused($focusField, equals: .name)
                                        }
                                        
                                        if viewStore.passwordOk {
                                            HStack(spacing:0){
                                                Text("비밀번호 확인")
                                                    .font(.system(size: 14))
                                                    .foregroundColor(.black)
                                                    .fontWeight(.heavy)
                                                if viewStore.password != viewStore.passwordConfirm {
                                                    Text("비밀번호가 일치하지 않습니다")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(Color("red"))
                                                        .padding(.leading, 5)
                                                }
                                            }.padding(.top, 15)
                                                .padding(.leading, 21)
                                            
                                            RoundedTextField(
                                                text: Binding(
                                                    get: { viewStore.passwordConfirm },
                                                    set: {
                                                        viewStore.send(.passwordConfirmChanged($0))
                                                        
                                                    }
                                                ),
                                                isValid: .constant(viewStore.password == viewStore.passwordConfirm),
                                                placeHolder: "비밀번호 확인",
                                                type: .password,
                                                verticalPadding: 8,
                                                horizontalPadding: 13
                                            ){
                                                // submit action
                                                viewStore.send(.submitPasswordConfirm)
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
                                            text: Binding(
                                                get: { viewStore.password },
                                                set: {
                                                    viewStore.send(.passwordChanged($0))
                                                }
                                            ),
                                            isValid: .constant(viewStore.password.validatePassword()),
                                            placeHolder: "비밀번호",
                                            type: .password,
                                            verticalPadding: 8,
                                            horizontalPadding: 13
                                        ){
                                            // submit action
                                            viewStore.send(.submitPassword)
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
                            
                            
                            
                            if viewStore.password.validatePassword() && viewStore.password == viewStore.passwordConfirm && !viewStore.name.isEmpty && viewStore.isAgreePrivacyPolicy {
                                Button {
                                    // 회원가입
                                    viewStore.send(.requestRegister(email))
                                } label: {
                                    Text("회원가입")
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                        .frame(maxWidth: .infinity)
                                }
                                .background(Color("main_blue"))
                                .cornerRadius(100)
                                .shadow(radius: 3, y:5)
                                .padding(.horizontal, 20)
                                .padding(.bottom, keyboard.isShowing ? keyboard.height : 47)
                            }
                        }
                        .roundedCorner(40, corners: [.topLeft, .topRight])
                        .padding(.top, 18)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.keyboard)
                .animation(.spring(), value: self.keyboard.isShowing)
                .onAppear {
                    viewStore.send(.onAppear)
                    self.keyboard.addObserver()
                }
                .onDisappear {
                    viewStore.send(.onDisappear)
                    self.keyboard.removeObserver()
                }
                .onChange(of: viewStore.focusField, perform: { newValue in
                    self.focusField = newValue
                })
                .onChange(of: viewStore.isSuccessJoin, perform: { newValue in
                    if newValue {
                        self.goToRootView.toggle()
                    }
                })
                .alert(
                    self.store.scope(state: \.alert),
                    dismiss: .dismissAlert
                )
            }
        }
    }
    
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView(
            email: "",
            goToRootView: .constant(false),
            store: Store(initialState: RegisterFeature.State(), reducer: RegisterFeature())
        )
    }
}

