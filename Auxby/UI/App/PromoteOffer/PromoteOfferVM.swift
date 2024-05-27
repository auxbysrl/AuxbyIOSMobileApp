//
//  PromoteOfferVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.05.2023.
//

import Foundation
import Combine

class PromoteOfferVM {
    var promoteList = [Promote(days: 1, price: 5), Promote(days: 7, price: 30), Promote(days: 30, price: 120)]
    var user: User
    var offer: Offer?
    var selectedPromoted: Promote
    var isFromPreview: Bool
    @Published private(set) var getPromoteOfferState = RequestState<Void>.idle
    @Published private(set) var getUserState = RequestState<User>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(isFromPreview: Bool, offer: Offer?) {
        selectedPromoted = promoteList[1]
        self.offer = offer
        self.isFromPreview = isFromPreview
        user = Offline.currentUser!
    }
    
    func promoteOffer() {
        getPromoteOfferState = .loading
        Network.shared.voidRequest(endpoint: .promoteOffer(offerID: offer?.id ?? 0, expirationDate: selectedPromoted.getExpirationDate(), requiredCoins: selectedPromoted.price))
            .assign(to: &$getPromoteOfferState)
    }
    
    func getUser() {
        getUserState = .loading
        Network.shared.request(endpoint: .getUser)
            .assign(to: &$getUserState)
    }
}
