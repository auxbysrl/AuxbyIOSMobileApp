//
//  FilterVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 05.07.2023.
//

import Foundation
import Combine

class FilterVM {
    var category: CategoryDetails?
    var subcategories: [String] = []
    var subcategoriesIds: [Int] = []
    var subcategoriesNames: [String] = []
    var selectedSubcategory: String = ""
    var selectedSubcategoryId: Int?
    var parentsOfView: [ParentOfView] = []
    var details: [NewOffer.Values] = []
    @Published private(set) var getSearchState = RequestState<[Offer]>.idle
    var cancellables: Set<AnyCancellable> = []
    var text = ""
    
    var startPrice: Double?
    var endPrice: Double?
    var location: String?
    var offerType: OfferType?
    var condition: ConditionType?
    var currency: CurrencyType = .ron
    
    func searchWithFilter(filter: SearchWithFilter) {
        getSearchState = .loading
        Network.shared.request(endpoint: .searchOffersWithFilter(search: filter))
            .assign(to: &$getSearchState)
    }

    convenience init(category: CategoryDetails, text: String) {
        self.init()
        self.category = category
        subcategories = category.subcategories.map { $0.label.translationText }
        subcategoriesIds = category.subcategories.map { $0.id }
        subcategoriesNames = category.subcategories.map { $0.name }
        self.text = text
    }
    
    convenience init(text: String) {
        self.init()
        self.text = text
    }
}
