//
//  ListOfBiddersVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.08.2023.
//

import Foundation

class ListOfBiddersVM {
    // MARK: - Public properties
    var bids: [Bid]
    var currencyType: String
    
    // MARK: Overriden Methods
    init(bids: [Bid], currencyType: String) {
        self.bids = bids
        self.currencyType = currencyType
    }
}
