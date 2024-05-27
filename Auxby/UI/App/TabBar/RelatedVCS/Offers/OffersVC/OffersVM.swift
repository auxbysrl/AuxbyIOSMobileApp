//
//  OffersVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation
import Combine

final class OffersVM {
    
    // MARK: - Public properties
    var categories: [Category] = []
    var offers: [Offer] = []
    var currentPromotedOffers: [Offer] = []
    var currentPage = 0
    var totalPages = 0
    var isLoading = true
    var isRefreshing = false
    @Published private(set) var getCategoriesState = RequestState<[Category]>.idle
    @Published private(set) var getOffersState = RequestState<OfferResponse>.idle
    @Published private(set) var getOffersByCategoryState = RequestState<OfferResponse>.idle
    @Published private(set) var getPromotedOffersState = RequestState<[Offer]>.idle
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    @Published private(set) var getNotificationsState = RequestState<[AppNotification]>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        if let currentCategories = Offline.decode(key: .categories, type: [Category].self) {
            categories = currentCategories
        }
        if let currentOffers = Offline.decode(key: .offers, type: [Offer].self) {
            offers = currentOffers
        }
    }
    
    func getCategories() {
        getCategoriesState = .loading
        Network.shared.request(endpoint: .getCategories)
            .assign(to: &$getCategoriesState)
    }
    
    func getPromotedOffers() {
        getPromotedOffersState = .loading
        Network.shared.request(endpoint: .getPromoted)
            .assign(to: &$getPromotedOffersState)
    }
    
    func getOffersByCategory(categoryId: Int) {
        getOffersState = .loading
        Network.shared.request(endpoint: .getOffersByCategory(categoryID: categoryId, page: 0))
            .assign(to: &$getOffersByCategoryState)
    }
    
    func getOffers() {
        getOffersState = .loading
        Network.shared.request(endpoint: .getOffers(page: currentPage))
            .assign(to: &$getOffersState)
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
