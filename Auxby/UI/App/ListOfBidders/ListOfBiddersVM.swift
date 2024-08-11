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
    var currencySymbol: String
    
    // MARK: Overriden Methods
    init(bids: [Bid], currencySymbol: String) {
        self.bids = bids
        self.currencySymbol = currencySymbol
    }
}
