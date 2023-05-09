//
//  lymcar_SwiftUIApp.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import Firebase
import ComposableArchitecture

@main
struct lymcar_SwiftUIApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            WelcomeView(
                store: Store(initialState: WelcomeFeature.State(), reducer: WelcomeFeature())
            )
                .onAppear {
                    UIApplication.shared.addTapGestureRecognizer()
                }
        }
    }
}
