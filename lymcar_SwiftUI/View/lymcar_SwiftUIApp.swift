//
//  lymcar_SwiftUIApp.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/14.
//

import SwiftUI
import Firebase


@main
struct lymcar_SwiftUIApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .onAppear {
                    UIApplication.shared.addTapGestureRecognizer()
                }
        }
    }
}
