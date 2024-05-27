//
//  OfferByCategoryVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 13.02.2023.
//

import Foundation
import Combine

class OffersByCategoryVM {
    // MARK: - Public properties
    var selectedCategory: Category
    var filteredOffers: [Offer] = []
    var currentPage = 0
    var totalPages = 0
    var isLoading = true
    @Published private(set) var getOffersState = RequestState<OfferResponse>.idle
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(selectedCategory: Category) {
        self.selectedCategory = selectedCategory
        if let staticOffers = Offline.decode(key: .offers, type: [Offer].self) {
            staticOffers.forEach {
                if $0.categoryId == selectedCategory.id {
                    filteredOffers.append($0)
                }
            }
        }
        getOffers()
    }
    
    func getOffers() {
        getOffersState = .loading
        Network.shared.request(endpoint: .getOffersByCategory(categoryID: selectedCategory.id, page: currentPage))
            .assign(to: &$getOffersState)
    }
    
    func addOrRemoveFromFavorite(id: Int) {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: id))
            .assign(to: &$getAddToFavoriteState)
    }
}
