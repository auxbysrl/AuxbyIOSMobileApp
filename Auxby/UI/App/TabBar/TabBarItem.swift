//
//  TabBarItem.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.10.2022.
//
import Foundation
import UIKit

enum TabBarItem {
    case offers, favorite, chat, bids
    
    static private(set) var offersVC = OffersVC.asVC()
    static private(set) var favoriteVC = FavoriteVC.asVC()
    static private(set) var chatVC = ChatVC.asVC()
    static private(set) var bidsVC  = BidsVC.asVC()
   
    
    init?(string: String) {
        switch string {
        case "Offers": self = .offers
        case "Favourite": self = .favorite
        case "Chat": self = .chat
        case "Bids": self = .bids
        default:        fatalError("Case not treated")
        }
    }
    
    /// Create a new instance for all tab bar screens
    static func reset() {
        offersVC = OffersVC.asVC()
        favoriteVC = FavoriteVC.asVC()
        chatVC = ChatVC.asVC()
        bidsVC  = BidsVC.asVC()
        
    }
    
    var vc: UIViewController! {
        switch self {
        case .offers: return TabBarItem.offersVC
        case .favorite: return TabBarItem.favoriteVC
        case .chat: return TabBarItem.chatVC
        case .bids: return TabBarItem.bidsVC
        }
    }
    
    var tag: Int {
        switch self {
        case .offers: return 1
        case .favorite: return 2
        case .chat: return 3
        case .bids: return 4
        }
    }
}
