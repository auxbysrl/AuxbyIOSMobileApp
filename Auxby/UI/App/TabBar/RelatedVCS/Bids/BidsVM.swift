//
//  BidsVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.04.2023.
//

import Foundation
import Combine

class BidsVM {
    var activeOffers: [Offer] = []
    var innactiveOffers: [Offer] = []
    var selectAction: ((_ isFirst: Bool) -> Void)?
    var isFirstTime = true
    
    var cancellables: Set<AnyCancellable> = []
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    @Published private(set) var getUserBidsState = RequestState<[Offer]>.idle
    @Published private(set) var getNotificationsState = RequestState<[AppNotification]>.idle
    
    func getUserBids() {
        getUserBidsState = .loading
        Network.shared.request(endpoint: .getUserBids)
            .assign(to: &$getUserBidsState)
    }
    
    func addOrRemoveFromFavorite(id: Int) {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: id))
            .assign(to: &$getAddToFavoriteState)
    }
    
    func getActiveAndInnactive() {
        if let offers = Offline.decode(key: .userBids, type: [Offer].self) {
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
    
    func getAllNotifications() {
        getNotificationsState = .loading
        Network.shared.request(endpoint: .getAllNotifications)
            .assign(to: &$getNotificationsState)
    }
}
