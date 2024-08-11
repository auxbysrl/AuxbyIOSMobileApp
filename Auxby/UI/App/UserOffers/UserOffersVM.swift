//
//  UserOffersVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.06.2024.
//

import Foundation
import Combine

class UserOffersVM {
    var owner: Owner
    var offers: [Offer] = []
    var currentPage = 0
    var totalPages = 0
    var isLoading = true
    @Published private(set) var getUserOffers = RequestState<OfferResponse>.idle
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(owner: Owner) {
        self.owner = owner
    }
    
    func addOrRemoveFromFavorite(id: Int) {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: id))
            .assign(to: &$getAddToFavoriteState)
    }
    
    func getOffers() {
        getUserOffers = .loading
        Network.shared.request(endpoint: .getOwnerOffers(email: owner.userName ?? "", page: currentPage))
            .assign(to: &$getUserOffers)
    }
}
