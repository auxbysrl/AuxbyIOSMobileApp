//
//  NotificationVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 04.09.2023.
//

import Foundation
import Combine

class NotificationsVM {
    var notifications: [AppNotification] = []
    @Published private(set) var getNotificationsState = RequestState<[AppNotification]>.idle
    @Published private(set) var getDeleteState = RequestState<Bool>.idle
    var cancellables: Set<AnyCancellable> = []
    
    func getAllNotifications() {
        getNotificationsState = .loading
        Network.shared.request(endpoint: .getAllNotifications)
            .assign(to: &$getNotificationsState)
    }
    
    func deleteNotification(id: Int) {
        getDeleteState = .loading
        Network.shared.request(endpoint: .deleteNotification(id: id))
            .assign(to: &$getDeleteState)
    }
    
    
}
