//
//  Chat.swift
//  Auxby
//
//  Created by Eduard Hutu on 12.07.2023.
//

import Foundation

class Chat: Codable {
    var roomId: Int
    var guest: String
    var roomName: String
    var offerId: Int
    var chatImage: String
    var host: String
    var lastMessageTime: String
    var isRoomHost: Bool
}

class CompleteChat: Codable {
    var chat: Chat
    var readDate: Date?
    
    init(chat: Chat, readDate: Date?) {
        self.chat = chat
        self.readDate = readDate
    }
}
