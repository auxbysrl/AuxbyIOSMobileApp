//
//  OfferDetails.swift
//  Auxby
//
//  Created by Eduard Hutu on 20.02.2023.
//

import Foundation
class OfferDetails: Codable {
    var id: Int
    var title: String
    var location: String
    var description: String
    var categoryId: Int
    var auctionStartDate: String?
    var auctionEndDate: String?
    var publishDate: String?
    var expirationDate: String?
    var isOnAuction: Bool
    var price: Double
    var currencyType: String?
    var owner: Owner?
    var highestBid: Double?
    var bids: [Bid]?
    var photos: [Photo]?
    var details: [Details]?
    var viewsNumber: Int?
    var setAsFavoriteNumber: Int?
    var isUserFavorite: Bool?
    var status: String?
    var phoneNumbers: String?
    var condition: String?
    var autoExtend: Bool
    var isPromoted: Bool
    
    init(id: Int, title: String, location: String, description: String, categoryId: Int, auctionStartDate: String? = nil, auctionEndDate: String? = nil, publishDate: String? = nil, expirationDate: String? = nil, isOnAuction: Bool, price: Double, currencyType: String? = nil, owner: Owner? = nil, highestBid: Double? = nil, bids: [Bid]? = nil, photos: [Photo]? = nil, details: [Details]? = nil, viewsNumber: Int, setAsFavoriteNumber: Int, status: String, isPromoted: Bool) {
        self.id = id
        self.title = title
        self.location = location
        self.description = description
        self.categoryId = categoryId
        self.auctionStartDate = auctionStartDate
        self.auctionEndDate = auctionEndDate
        self.publishDate = publishDate
        self.expirationDate = expirationDate
        self.isOnAuction = isOnAuction
        self.price = price
        self.currencyType = currencyType
        self.owner = owner
        self.highestBid = highestBid
        self.bids = bids
        self.photos = photos
        self.details = details
        self.viewsNumber = viewsNumber
        self.setAsFavoriteNumber = setAsFavoriteNumber
        self.status = status
        self.autoExtend = false
        self.isPromoted = isPromoted
    }
    
    func toOffer() -> Offer {
        return Offer(id: id, title: title, location: location, description: description, categoryId: categoryId, price: price, isOnAuction: isOnAuction, auctionStartDate: auctionStartDate, auctionEndDate: auctionEndDate, owner: owner, publishDate: publishDate, expirationDate: expirationDate, currencyType: currencyType, bids: bids, highestBid: highestBid, photos: photos, isUserFavorite: isUserFavorite, isPromoted: isPromoted)
    }
}

class Details: Codable {
    var key: String
    var value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    func toValue()-> NewOffer.Values {
        return NewOffer.Values(key: self.key, value: self.value)
    }
}
