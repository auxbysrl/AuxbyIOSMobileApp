//
//  Offer.swift
//  Auxby
//
//  Created by Eduard Hutu on 11.11.2022.
//

import Foundation
import L10n_swift

class Offer: Codable {
    var id: Int
    var title: String
    var location: String
    var description: String
    var categoryId: Int
    var price: Double
    var isOnAuction: Bool
    var status: String?
    var auctionStartDate: String?
    var auctionEndDate: String?
    var owner: Owner?
    var publishDate: String?
    var expirationDate: String?
    var currencyType: String?
    var currencySymbol: String?
    var bids: [Bid]?
    var highestBid: Double?
    var photos: [Photo]?
    var isUserFavorite: Bool?
    var isPromoted: Bool
    
    init(id: Int, title: String, location: String, description: String, categoryId: Int, price: Double, isOnAuction: Bool, isAvailable: Bool? = nil, auctionStartDate: String? = nil, auctionEndDate: String? = nil, owner: Owner? = nil, publishDate: String? = nil, expirationDate: String? = nil, currencyType: String? = nil, bids: [Bid]? = nil, highestBid: Double? = nil, photos: [Photo]? = nil, isUserFavorite: Bool? = nil, isPromoted: Bool) {
        self.id = id
        self.title = title
        self.location = location
        self.description = description
        self.categoryId = categoryId
        self.price = price
        self.isOnAuction = isOnAuction
        self.auctionStartDate = auctionStartDate
        self.auctionEndDate = auctionEndDate
        self.owner = owner
        self.publishDate = publishDate
        self.expirationDate = expirationDate
        self.currencyType = currencyType
        self.bids = bids
        self.highestBid = highestBid
        self.photos = photos
        self.isUserFavorite = isUserFavorite
        self.isPromoted = isPromoted
    }
    
    enum offerStatus {
        case active
        case inactive
        case finished
        case interrupted
        var status: String {
            switch self {
            case .active:
                return "Active"
            case .inactive:
                return "Inactive"
            case .finished:
                return "Finished"
            case .interrupted:
                return "Interrupted"
            }
        }
        
    }
}

class Bid: Codable {
    var userName: String
    var bidValue: Double
    var bidDate: String
    var userAvatar: String?
    var email: String
    var winner: Bool
    var phone: String?
    var lastSeen: String
    
    func getActiveString()-> String {
        var activeString = ""
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ro_RO")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let lastActiveDate = dateFormatter.date(from: self.bidDate)!
        let calendar = Calendar.current
        if calendar.isDateInToday(lastActiveDate) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            activeString = "today".l10n() + " " + "at".l10n() +  " \(formatter.string(from: lastActiveDate))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            activeString = " \(formatter.string(from: lastActiveDate))"
        }
        return activeString
    }
}

class Photo: Codable {
    var url: String?
    var isPrimary: Bool
}

class Owner: Codable {
    var lastName: String?
    var firstName: String?
    var userName: String?
    var phone: String?
    var avatarUrl: String?
    var lastSeen: String?
    var rating: Int
    static let noProfilePhoto = "NoProfilePhoto"
    
    func getActiveString()-> String {
        var activeString = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ro_RO")
        let lastActiveDate = dateFormatter.date(from: self.lastSeen!)!
        let calendar = Calendar.current
        if calendar.isDateInToday(lastActiveDate) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            activeString = "active".l10n() +  " " + "today".l10n() + " " + "at".l10n() +  " \(formatter.string(from: lastActiveDate))"
        } else if calendar.isDateInYesterday(lastActiveDate) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            activeString = "active".l10n() +  " " + "yesterday".l10n() + " " + "at".l10n() +  " \(formatter.string(from: lastActiveDate))"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            activeString = "active".l10n() + " \(formatter.string(from: lastActiveDate))"
        }
        return activeString
    }
}

