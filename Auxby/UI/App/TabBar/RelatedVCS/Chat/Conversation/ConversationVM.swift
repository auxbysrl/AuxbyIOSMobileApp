//
//  ConversationVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.05.2023.
//

import Foundation
import Combine

class ConversationVM {
    let chat: Chat
    var messages: [Message] = []
    var completeListMessages: [Message] = []
    var lastDate = ""
    var text = ""
    var isFirst = true
    var cancellables: Set<AnyCancellable> = []
    @Published private(set) var getMessagesState = RequestState<[Message]>.idle
    @Published private(set) var sendMessagesState = RequestState<[Message]>.idle
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    func getMessages() {
        getMessagesState = .loading
        Network.shared.request(endpoint: .getMessages(chatID: chat.roomId))
            .assign(to: &$getMessagesState)
    }
    
    func sendMessage(message: String) {
        sendMessagesState = .loading
        Network.shared.request(endpoint: .sendMessage(message: message, chatID: chat.roomId))
            .assign(to: &$sendMessagesState)
    }
}
