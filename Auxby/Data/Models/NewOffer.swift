//
//  NewOffer.swift
//  Auxby
//
//  Created by Andrei Traciu on 01.02.2023.
//

import Foundation

class NewOffer: Codable {
    var title: String
    var description: String
    var requiredCoins: Int
    var price: Double
    var offerType: String
    var currencyType: String
    var conditionType: String
    var contactInfo: ContactInfo
    var categoryId: Int
    var auctionEndDate: String?
    var categoryDetails: [Values]
    var autoExtend: Bool
    
    init() {
        title = ""
        description = ""
        requiredCoins = 0
        price = 0
        offerType = ""
        currencyType = ""
        conditionType = ""
        contactInfo = ContactInfo(location: "", phoneNumber: "")
        categoryId = 0
        auctionEndDate = ""
        categoryDetails = []
        autoExtend = false
    }
    
    
    struct ContactInfo: Codable {
        var location: String
        var phoneNumber: String
        
        init(location: String, phoneNumber: String) {
            self.location = location
            self.phoneNumber = phoneNumber
        }
    }
    
    struct Values: Codable {
        var key: String
        var value: String
        
        init(key: String, value: String) {
            self.key = key
            self.value = value
        }
    }
}

protocol NewOfferValue {
    var value: NewOffer.Values { get set }
}
