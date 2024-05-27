//
//  PlaceBidVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.03.2023.
//

import Foundation
import Combine

class PlaceBidVM {
    var offer: OfferDetails
    var bidPrice: Int = 100
    var user: User
    var yourBid: Int
    var highestBid: Int
    var minimExtraBid: Int
    var maxValue = 999999999
    
    @Published private(set) var getBidState = RequestState<AddBidResponse>.idle
    @Published private(set) var getOfferState = RequestState<OfferDetails>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(offer: OfferDetails) {
        self.offer = offer
        user = Offline.currentUser!
        if let categories =  Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
            if let cat = categories.first(where: { $0.id == offer.categoryId }) {
                bidPrice = cat.placeBidCost
            }
        }
        minimExtraBid = Int(offer.price * 0.1)
        highestBid = offer.highestBid! > 0 ? Int(offer.highestBid!) : Int(offer.price)
        yourBid = highestBid + minimExtraBid
    }
    
    func resetOffer(offer: OfferDetails) {
        self.offer = offer
        user = Offline.currentUser!
        if let categories =  Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
            if let cat = categories.first(where: { $0.id == offer.categoryId }) {
                bidPrice = cat.placeBidCost
            }
        }
        minimExtraBid = Int(offer.price * 0.1)
        highestBid = offer.highestBid! > 0 ? Int(offer.highestBid!) : Int(offer.price)
        yourBid = highestBid + minimExtraBid
    }
    
    func placeBid(amount: Int) {
        getBidState = .loading
        Network.shared.request(endpoint: .placeBid(id: offer.id, amount: amount, requiredCoind: bidPrice))
            .assign(to: &$getBidState)
    }
    
    func getOffer() {
        getOfferState = .loading
        Network.shared.request(endpoint: .getOfferBy(id: offer.id, increaseView: false))
            .assign(to: &$getOfferState)
    }
}
