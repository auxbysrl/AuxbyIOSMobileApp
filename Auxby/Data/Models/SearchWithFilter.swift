//
//  SearchWithFilter.swift
//  Auxby
//
//  Created by Eduard Hutu on 10.07.2023.
//

import Foundation

class SearchWithFilter: Codable {
    //var detailsFilters: [DetailsFilter]
    var conditionType: String?
    var priceFilter: PriceFilter?
    var location: String?
    var categories: [Int]
    var offerType : String?
    var title: String?
    
    init (condition: String? = nil, priceFilter: PriceFilter? = nil, location: String? = nil, categories: [Int], offerType: String? = nil, title: String? = nil) {
        self.conditionType = condition
        self.priceFilter = priceFilter
        self.location = location
        self.categories = categories
        self.title = title
        self.offerType = offerType
    }
}

class DetailsFilter: Codable {
    var key: String
    var value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
}

class PriceFilter: Codable {
    var highestPrice: Double?
    var lowestPrice: Double?
    var currencyType: String
    
    init(highestPrice: Double?, lowestPrice: Double?, currencyType: String) {
        self.highestPrice = highestPrice
        self.lowestPrice = lowestPrice
        self.currencyType = currencyType
    }
}
