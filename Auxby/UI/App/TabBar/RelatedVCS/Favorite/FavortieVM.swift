//
//  FavortieVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 23.03.2023.
//

import Foundation
import Combine

class FavoriteVM {
    var favoriteOffers: [Offer] = []
    var cancellables: Set<AnyCancellable> = []
    @Published private(set) var getFavoritesState = RequestState<[Offer]>.idle
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    @Published private(set) var getNotificationsState = RequestState<[AppNotification]>.idle
    
    func getFavorites() {
        getFavoritesState = .loading
        Network.shared.request(endpoint: .getFavorites)
            .assign(to: &$getFavoritesState)
    }
    
    func addOrRemoveFromFavorite(id: Int) {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: id))
            .assign(to: &$getAddToFavoriteState)
    }
    
    func getAllNotifications() {
        getNotificationsState = .loading
        Network.shared.request(endpoint: .getAllNotifications)
            .assign(to: &$getNotificationsState)
    }
}
