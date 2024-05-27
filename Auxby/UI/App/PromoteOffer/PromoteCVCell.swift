//
//  PromoteCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.05.2023.
//

import UIKit
import L10n_swift

class PromoteCVCell: UICollectionViewCell {
    
    @IBOutlet weak var promoteImage: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    
    func setCell(promote: Promote, isSelected: Bool) {
        promoteImage.image = UIImage(named: "\(promote.days).")
        let timeText = promote.days == 1 ?  "day".l10n() : "days".l10n()
        textLabel.text = "promoteOfferFor".l10n() + " \(promote.days) " + timeText
        mainView.borderWidth = isSelected ? 1 : 0
    }
}
