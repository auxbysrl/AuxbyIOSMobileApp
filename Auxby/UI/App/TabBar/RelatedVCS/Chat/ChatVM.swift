//
//  ChatVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 12.07.2023.
//

import Foundation
import Combine

class ChatVM {
    var cancellables: Set<AnyCancellable> = []
    @Published private(set) var getChatsState = RequestState<[Chat]>.idle
    @Published private(set) var getNotificationsState = RequestState<[AppNotification]>.idle
    var selectAction: ((_ isFirst: Bool) -> Void)?
    var chats: [Chat] = []
    var buyChats: [CompleteChat] = []
    var sellChats: [CompleteChat] = []
    
    func getChats() {
        getChatsState = .loading
        Network.shared.request(endpoint: .getUserChats)
            .assign(to: &$getChatsState)
    }
    
    func setButtons(isFirst: Bool) {
        selectAction?(isFirst)
    }
    
    func getAllNotifications() {
        getNotificationsState = .loading
        Network.shared.request(endpoint: .getAllNotifications)
            .assign(to: &$getNotificationsState)
    }
}
