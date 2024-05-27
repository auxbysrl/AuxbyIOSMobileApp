//
//  Category.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation
import L10n_swift

class Category: Codable {
    var id: Int
    var icon: String
    var label: [Label]
    var noOffers: Int
    
    init() {
        id = 0
        icon = ""
        label = []
        noOffers = 0
    }
    
    init (id: Int, icon: String, label: [Label]) {
        self.id = id
        self.icon = icon
        self.label = label
        noOffers = 0
    }
}

class Label: Codable {
    var language: String
    var translation: String
    
    init() {
        language = ""
        translation = ""
    }
    
    init(language: String, translation: String) {
        self.language = language
        self.translation = translation
    }
}

extension Array where Element: Label {
    var translationText: String {
        return self.first(where: { $0.language == L10n.shared.language })?.translation ?? "not found"
    }
}
