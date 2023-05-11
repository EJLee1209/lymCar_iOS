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
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            WelcomeView(
                store: Store(initialState: WelcomeFeature.State(), reducer: WelcomeFeature())
            )
            .environmentObject(appDelegate)
                .onAppear {
                    UIApplication.shared.addTapGestureRecognizer()
                }
                
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    var fcmToken: String = ""
    @ObservedObject var realmManager = RealmManger()
    // 앱이 켜졌을 때
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 대리인에게 실행 프로세스가 완료되었으며 앱을 실행할 준비가 되었음을 알림
        
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 원격 알림 등록
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: { _, _ in }
        )
        
        
        application.registerForRemoteNotifications()
        
        // 메세징 델리겟
        Messaging.messaging().delegate = self
        
        // 푸시 포그라운드 설정
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // fcm 토큰이 등록되었을 때
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // 앱이 apns에 성공적으로 등록되었음을 대리자에게 알림
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension AppDelegate: MessagingDelegate {
    // fcm 등록 토큰을 받았을 때
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("AppDelegate - 파베 토큰을 받았다.")
        print("fcm token : \(String(describing: fcmToken))")
        self.fcmToken = fcmToken ?? ""
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 푸시메세지가 앱이 켜져 있을 때 나올 때
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // 앱이 포그라운드에서 실행되는 동안 도착한 알림을 처리하는 곳
        completionHandler([.banner, .sound, .badge])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // 푸시 알림이 왔을 때
        let roomId = userInfo["roomId"] as! String
        let userId = userInfo["userId"] as! String
        let userName = userInfo["userName"] as! String
        let msg = userInfo["message"] as! String
        let dateTime = userInfo["dateTime"] as! String
        let messageType = userInfo["messageType"] as! String
        let chatToSave = Chat(value: [
            "roomId" : roomId,
            "userId" : userId,
            "userName" : userName,
            "msg" : msg,
            "dateTime" : dateTime,
            "messageType" : messageType,
            "sendSuccess" : SEND_STATE_SUCCESS
        ])
        print("Receive silent push>", chatToSave)
        self.realmManager.saveChat(chat: chatToSave)
        completionHandler(.newData)
    }
}
