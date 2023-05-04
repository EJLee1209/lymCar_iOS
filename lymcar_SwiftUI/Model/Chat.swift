//
//  Chat.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/05/04.
//

import Foundation
import RealmSwift

struct Chat {
    let id: String = UUID().uuidString
    var roomId: String = ""
    var userId: String = ""
    var userName: String = ""
    var msg: String = ""
    let dateTime: String = Utils.getCurrentDateTime()
    var messageType: String = ""
    var sendSuccess: String = SEND_STATE_LOADING
}

extension Chat {
    var myMockList : [Chat] {
        return [
            Chat(
                userName: "개발자1",
                msg: "안녕하세요~",
                messageType: CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ),
            Chat(
                userName: "개발자2",
                msg: "반갑습니다",
                messageType: CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ),
            Chat(
                userName: "개발자3",
                msg: "ㅋㅋㅋㅋ",
                messageType: CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            ),
            Chat(
                userName: "개발자1",
                msg: "테스트 중 입니다",
                messageType: CHAT_NORMAL,
                sendSuccess: SEND_STATE_SUCCESS
            )
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
