//
//  AddBidResponse.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.03.2023.
//

import Foundation
class AddBidResponse: Codable {
    var wasBidAccepted = true
    var offerBids: [OfferBid] = []
}

class OfferBid: Codable {
    var user = ""
    var amount = 0
}

