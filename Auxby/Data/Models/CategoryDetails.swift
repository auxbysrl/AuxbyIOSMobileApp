//
//  CategoryDetails.swift
//  Auxby
//
//  Created by Andrei Traciu on 18.01.2023.
//

import Foundation

struct CategoryDetails: Codable {
    var id: Int
    var icon: String
    var name: String
    var addOfferCost: Int
    var placeBidCost: Int
    var label: [Label]
    var parentName: String
    var categoryDetails: [CategoryDetailsFields]
    var subcategories: [CategoryDetails]
    
    func toCategory() -> Category {
        return Category(id: self.id, icon: self.icon, label: self.label)
    }
}

extension CategoryDetails {
    init() {
        id = 0
        icon = ""
        name = ""
        label = []
        parentName = ""
        categoryDetails = []
        subcategories = []
        addOfferCost = 0
        placeBidCost = 0
    }
}

struct CategoryDetailsFields: Codable {
    var guiOrder: Int
    var parent: String
    var name: String
    var type: String
    var label: [Label]
    var placeholder: String?
    var required: Bool?
    var options: [CategoryDetailsOptions]
    var constraints: CategoryDetailsConstraints?
}

struct CategoryDetailsOptions: Codable {
    var name: String
    var childOptions: [String]?
    var parentOption: String?
    var label: [Label]
}

struct CategoryDetailsConstraints: Codable {
    var maxLength: Int?
    var maxLines: Int?
    var inputType: String?
}
