//
//  MyOffersVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 27.03.2023.
//

import Foundation
import Combine
 
class MyOffersVM {
    
    var activeOffers: [Offer] = []
    var innactiveOffers: [Offer] = []
    var selectAction: ((_ isFirst: Bool) -> Void)?
    
    var cancellables: Set<AnyCancellable> = []
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    @Published private(set) var getUserOffers = RequestState<[Offer]>.idle
  
    init() {
        getAcctiveAndInnactive()
    }
    
    
    
    func getUsersOffers() {
        getUserOffers = .loading
        Network.shared.request(endpoint: .getUserOffers)
            .assign(to: &$getUserOffers)
    }
    
    func addOrRemoveFromFavorite(id: Int) {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: id))
            .assign(to: &$getAddToFavoriteState)
    }
    
    func getAcctiveAndInnactive() {
        if let offers = Offline.decode(key: .userOffers, type: [Offer].self) {
            activeOffers = []
            innactiveOffers = []
            offers.forEach {
                if $0.status == Offer.offerStatus.active.status {
                    activeOffers.append($0)
                } else {
                    innactiveOffers.append($0)
                }
            }
        }
    }
    
    func setButtons(isFirst: Bool) {
        selectAction?(isFirst)
    }
}
