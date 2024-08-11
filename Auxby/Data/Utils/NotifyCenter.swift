//
//  NotifyCenter.swift
//  Auxby
//
//  Created by Eduard Hutu on 22.03.2023.
//

import Foundation
import Combine

/**
 NotificationCenter types.
 
 Cases are explicitly notification *Selector* name
 */
enum NotificationType: String {
    case updateOffers
    case noUser
    case filterOffers
    case newMessage
    case updateNotifications
    case updateUser
}

/**
 NotificationCenter handler class
 */

final class NotifyCenter {
    /**
     Creates a notification with a given NotificationType, data and posts it to the notification center.
     - Parameter type: The NotificationType you want posting
     - Parameter data: The Data that you want to send it via NotificationCenter; can be nil
     */
    class func post(_ type: NotificationType, data: Any? = nil) {
        var userInfo: [String: Any]?
        if let data = data { userInfo = ["data": data] }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: type.rawValue), object: nil, userInfo: userInfo)
    }
    
    class func removeFromObserve(_ type: NotificationType) {
        NotificationCenter.default.removeObserver(Notification.Name(type.rawValue))
    }
    
    /**
     Returns a generic AnyPublisher<T?, Never> type.
     
     Use this metod when you are waiting to receive data of specified dataType
     - Parameter type: The NotificationType you are posting
     - Parameter dataType: The type of the data that you are waiting for
     */
    class func observable<T: Any>(for type: NotificationType, dataType: T.Type) -> AnyPublisher<T?, Never> {
        NotificationCenter.default
            .publisher(for: Notification.Name(type.rawValue))
            .map { $0.userInfo?["data"] as? T }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    /**
     Returns a AnyPublisher<Void, Never>  type.
     
     Use this method when you are not expecting to receive any data
     - Parameter type: The NotificationType you are posting
     */
    class func observable(for notifyType: NotificationType) -> AnyPublisher<Void, Never> {
        NotificationCenter.default
            .publisher(for: Notification.Name(notifyType.rawValue))
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
