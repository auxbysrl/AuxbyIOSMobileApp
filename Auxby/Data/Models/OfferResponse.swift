//
//  OfferResponse.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.11.2022.
//

import Foundation

class OfferResponse: Codable {
    var content: [Offer]
    var totalElements: Int
    var totalPages: Int
    var page: Int
    var size: Int
    
    init(content: [Offer], totalElements: Int, totalPages: Int, page: Int, size: Int) {
        self.content = content
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.page = page
        self.size = size
    }
}
