//
//  TabBarVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.10.2022.
//

import Foundation
import Combine

class TabBarVM {
    var selectedTag = 1
    var categoriesDetails: [CategoryDetails] = []
    var cancellables: Set<AnyCancellable> = []
    @Published private(set) var getFavoritesState = RequestState<[Offer]>.idle
    @Published private(set) var getAddState = RequestState<[Add]>.idle
    var favorites: [Offer] = []
    
    func getFavorites() {
        getFavoritesState = .loading
        Network.shared.request(endpoint: .getFavorites)
            .assign(to: &$getFavoritesState)
    }
    
    func getAdd() {
        getAddState = .loading
        Network.shared.request(endpoint: .getAdds)
            .assign(to: &$getAddState)
    }
}
