//
//  SearchVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 29.06.2023.
//

import Foundation
import Combine

class SearchVM {
    var searchedOffers: [Offer] = []
    @Published private(set) var getSearchState = RequestState<[Offer]>.idle
    @Published private(set) var getSearchPerCategory = RequestState<SearchResult>.idle
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    var cancellables: Set<AnyCancellable> = []
    var serchedText = ""
    var resultOfSearch: SearchResult?
    var selectedCategory: CategoryDetails?
    var isSubcategory = false
    var selectedCategoryId = 0
    
    func searchPerCategory(text: String) {
        getSearchPerCategory = .loading
        Network.shared.request(endpoint: .searchPerCategory(text: text))
            .assign(to: &$getSearchPerCategory)
    }
    
    func searchOffers(search: SearchByCategory) {
        getSearchState = .loading
        Network.shared.request(endpoint: .searchOffers(search: search))
            .assign(to: &$getSearchState)
    }
    
    func addOrRemoveFromFavorite(id: Int) {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: id))
            .assign(to: &$getAddToFavoriteState)
    }
}
