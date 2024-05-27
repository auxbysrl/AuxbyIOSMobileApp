//
//  SearchCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 29.06.2023.
//

import UIKit
import L10n_swift

class SearchCVCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var searchTitle: UILabel!
    @IBOutlet weak var categoryTitle: UILabel!
    
    func setCell(search: String, category: Category, numberOfSearch: Int ) {
        categoryImage.setImage(from: category.icon)
        searchTitle.text = search
        let categoryName = category.label.first(where: { $0.language == L10n.shared.language
        })?.translation ?? "All offers"
        categoryTitle.text = "\(numberOfSearch) in \(categoryName)"
    }
}
