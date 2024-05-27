//
//  Message.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.05.2023.
//

import Foundation

class Message: Codable {
    var messageText: String
    var sender: String
    var messageTime: String
    
    init(messageText: String, sender: String, messageTime: String) {
        self.messageText = messageText
        self.sender = sender
        self.messageTime = messageTime
    }
}
