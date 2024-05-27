//
//  CategoryCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.11.2022.
//

import UIKit
import L10n_swift

class CategoryCell: UICollectionViewCell {
    
     // MARK: - IBOutlets
    @IBOutlet private weak var noOffers: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var categoryImage: UIImageView!
    
    func setCell(category: Category) {
        if category.icon.first == "." {
            category.icon.remove(at: category.icon.startIndex)
        }
        var url = ""
        if ApiRequest.isProduction {
            url = "https://" + ApiRequest.baseURL + ":8080" + category.icon
        } else {
            url = "https://" + ApiRequest.baseURL + category.icon
        }
        categoryImage.setImage(from: url)
        titleLabel.text = category.label.first(where: { $0.language == L10n.shared.language
        })?.translation
        let text = category.noOffers == 0 ? "noOffers".l10n() : category.noOffers == 1 ? "1 " + "offer".l10n() : "\(category.noOffers) " + "offers".l10n()
        noOffers.text = text
    }
    
    func setCell(categoryDetails: CategoryDetails) {
        var iconURL = categoryDetails.icon
        if iconURL.first == "." {
            iconURL.remove(at: iconURL.startIndex)
        }
        let url = "https://" + ApiRequest.baseURL + ":8080" + iconURL
        categoryImage.setImage(from: url)
        
        titleLabel.text = categoryDetails.label.first(where: { $0.language == L10n.shared.language })?.translation
        
        noOffers.text = ""
        noOffers.isHidden = true
    }
}
