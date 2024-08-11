//
//  Currency.swift
//  Auxby
//
//  Created by Eduard Hutu on 04.06.2024.
//

import Foundation

class Currency: Codable {
    var name: String
    var symbol: String
    
    init(name: String, symbol: String) {
        self.name = name
        self.symbol = symbol
    }
}

struct Price {
    var value: Double
    var currency: Currency
}

class Add: Codable {
    var code: String
    var text: String
    var image: String
    var categoryId: Int?
}

class AddDetails: Codable {
    var add: Add
    var hasSeen: Bool = false
    init(add: Add) {
        self.add = add
        self.hasSeen = false
    }
}
