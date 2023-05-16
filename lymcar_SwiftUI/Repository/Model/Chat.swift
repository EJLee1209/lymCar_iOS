//
//  Chat.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/04.
//

import Foundation
import RealmSwift

class Chat: Object {
    @Persisted(primaryKey: true) var id: String = UUID().uuidString
    @Persisted var roomId: String = ""
    @Persisted var userId: String = ""
    @Persisted var userName: String = ""
    @Persisted var msg: String = ""
    @Persisted var dateTime: String = Utils.getCurrentDateTime(isSep: false)
    @Persisted var messageType: String = ""
    @Persisted var sendSuccess: String = SEND_STATE_LOADING
}

extension Chat {
    var myMockList : [Chat] {
        return [
            Chat(value: [
                "userName" : "개발자",
                "msg" : "안녕하세요~",
                "messageType": CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ]),
            Chat(value: [
                "userName" : "개발자",
                "msg" : "안녕하세요~",
                "messageType": CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ]),
            Chat(value: [
                "userName" : "개발자",
                "msg" : "안녕하세요~",
                "messageType": CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ]),
            Chat(value: [
                "userName" : "개발자",
                "msg" : "안녕하세요~",
                "messageType": CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ])
        ]
    }
}

let CHAT_NORMAL = "NORMAL"
let CHAT_JOIN = "JOIN"
let CHAT_EXIT = "EXIT"
let CHAT_ETC = "ETC"

let SEND_STATE_FAIL = "FAIL"
let SEND_STATE_SUCCESS = "SUCCESS"
let SEND_STATE_LOADING = "LOADING"
