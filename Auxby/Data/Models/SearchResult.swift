//
//  SearchResult.swift
//  Auxby
//
//  Created by Eduard Hutu on 29.06.2023.
//

import Foundation

class SearchResult: Codable {
    var categoryResult: [String: Int]
    
    init(categoryResult: [String : Int]) {
        self.categoryResult = categoryResult
    }
}

class SearchByCategory: Codable {
    var categories: [Int]
    var title: String
    var detailsFilters: [Int]
    
    init( categories: [Int], title: String, detailsFilters: [Int] = []) {
        self.categories = categories
        self.title = title
        self.detailsFilters = detailsFilters
    }
}
