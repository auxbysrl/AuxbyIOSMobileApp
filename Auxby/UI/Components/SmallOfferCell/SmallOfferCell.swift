//
//  SmallOfferCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 02.07.2024.
//

import UIKit

class SmallOfferCell: UICollectionViewCell {
    @IBOutlet weak var offerView: SmallOfferView!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
    func setCell(offer: Offer, addToFav: (() -> Void)?, viewOffers: (() -> Void)?, showUsers: (() -> Void)?, isLeft: Bool) {
        leadingConstraint.constant = isLeft ? 16 : 0
        trailingConstraint.constant = isLeft ? 0 : 16
        offerView.setView(offer: offer, addToFav: addToFav, viewOffers: viewOffers, showUsers: showUsers)
    }
}
