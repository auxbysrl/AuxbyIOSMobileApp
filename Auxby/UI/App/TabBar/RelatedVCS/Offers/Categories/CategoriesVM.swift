//
//  CategoriesVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.11.2022.
//

import Foundation

class CategoriesVM {
    
    // MARK: - Public properties
    var categories: [Category] = []
    var filtredCategories: [Category] = []
    
    var shouldUseCategoryDetails: Bool = false
    var categoriesDetails: [CategoryDetails] = []
    var filtredCategoriesDetails: [CategoryDetails] = []
    var selectCategoryForFilter: ((CategoryDetails)->Void)?
    
    init() {
        if let currentCategories = Offline.decode(key: .categories, type: [Category].self) {
            categories = currentCategories
        }
        filtredCategories = categories
    }
    
    func filterCategories(name: String) {
        if shouldUseCategoryDetails {
            filtredCategoriesDetails = []
            categoriesDetails.forEach {
                if ($0.label.translationText.lowercased().contains(name.lowercased())) {
                    self.filtredCategoriesDetails.append($0)
                }
            }
            return
        }
        
        filtredCategories = []
        categories.forEach {
            if ($0.label.translationText.lowercased().contains(name.lowercased())) {
                self.filtredCategories.append($0)
            }
        }
    }
}
