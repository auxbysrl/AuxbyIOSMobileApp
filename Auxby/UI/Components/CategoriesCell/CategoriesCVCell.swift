//
//  CategoriesCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import UIKit
import L10n_swift

class CategoriesCVCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var title: UILabel!
    @IBOutlet private weak var offersCount: UILabel!
    @IBOutlet weak var mainView: UIView!
    
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
        image.setImage(from: url)
        title.text = category.label.first(where: { $0.language == L10n.shared.language
        })?.translation
        let text = category.noOffers == 0 ? "noOffers".l10n() : category.noOffers == 1 ? "1 " + "offer".l10n() : "\(category.noOffers) " + "offers".l10n()
        offersCount.text = text
    }
}
