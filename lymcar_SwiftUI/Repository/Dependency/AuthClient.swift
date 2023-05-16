//
//  AuthClient.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/08.
//

import Foundation
import ComposableArchitecture
import Firebase

struct AuthClient {
    var createUser: @Sendable(_ email: String, _ password: String, _ newUser: User) async throws -> Void
    var checkLogged: @Sendable(_ email: String) async throws -> Void
    var login: @Sendable(_ email: String, _ password: String) async throws -> Void
    
    static let auth = Firebase.Auth.auth()
    static let db = Firestore.firestore()
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

enum AuthError: Error {
    case alreadyLogged
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        createUser: { email, password, newUser in
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let user = authResult.user
            var copyUser = newUser
            copyUser.uid = user.uid
            
            try await db.collection(FireStoreTable.USER).document(user.uid)
                .setData(copyUser.dictionary)

            try await db.collection(FireStoreTable.FCMTOKENS).document(user.uid)
                .setData(TokenInfo().dictionary)
        },
        checkLogged: { email in
            let splitEmail = email.split(separator: "@")
            
            let snapshot = try await db.collection(FireStoreTable.SIGNEDIN).whereField(FireStoreTable.FIELD_EMAIL, isEqualTo: String(splitEmail[0])).getDocuments()
            
            guard let document = snapshot.documents.first else { return }
            let deviceId = document.get(FireStoreTable.FIELD_DEVICEID) as! String
            
            if deviceId != Utils.getDeviceUUID() {
                throw AuthError.alreadyLogged
            }
        },
        login: { email, password in
            let splitEmail = email.split(separator: "@")
            
            let authResult = try await auth.signIn(withEmail: email, password: password)
            let user = authResult.user
            
            try await db.collection(FireStoreTable.SIGNEDIN).document(user.uid)
                .setData(SignedIn(
                    uid: user.uid,
                    email: String(splitEmail[0]),
                    deviceId: Utils.getDeviceUUID()
                    ).dictionary
                )
        }
    )
}
