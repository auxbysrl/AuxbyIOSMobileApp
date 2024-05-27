//
//  Notification.swift
//  Auxby
//
//  Created by Eduard Hutu on 04.09.2023.
//

import Foundation
import L10n_swift

class AppNotification: Codable {
    var type: String
    var title: String
    var message: String
    var date: String
    var id: Int?
    var offerId: Int?
    var userId: Int?
}

enum AppNotificationType: String {
    case newChat = "NEW_CHAT_STARTED"
    case message = "NEW_MESSAGE_RECEIVED"
    case winner = "AUCTION_WON"
    case second = "BID_EXCEEDED"
    case finished = "AUCTION_ENDED"
    case interrupted = "AUCTION_INTERRUPTED"
    case failed = "ACTION_FAILED"
    
    
    var title: String {
        switch self {
        case .newChat:
            return "newChatTitle".l10n()
        case .message:
            return "newMessageTitle".l10n()
        case .winner:
            return "winnerTitle".l10n()
        case .second:
            return "secondTitle".l10n()
        case .finished:
            return "finishedTitle".l10n()
        case .interrupted:
            return "interruptedTitle".l10n()
        case .failed:
            return "failedTitle".l10n()
        }
    }
    
    var description: String {
        switch self {
        case .newChat:
            return "newChatDescription".l10n()
        case .message:
            return "newMessageDescription".l10n()
        case .winner:
            return "winnerDescription".l10n()
        case .second:
            return "secondDescription".l10n()
        case .finished:
            return "finishedDescription".l10n()
        case .interrupted:
            return "interruptedDescription".l10n()
        case .failed:
            return "failedDescription".l10n()
        }
    }
    
    func action(offerId: Int? = nil) {
        switch self {
        case .message, .newChat:
            topVC().popVC()
            TabBarVC.instance.goToChat()
        default:
            if let id = offerId {
                if let offer = Offline.decode(key: .offers, type: [Offer].self)?.first(where: { $0.id == id }) {
                    let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
                    offerDetailsVC.vm = PreviewOrDetailsVM(offer: offer)
                    topVC().pushVC(offerDetailsVC)
                }
            }
        }
    }
}
