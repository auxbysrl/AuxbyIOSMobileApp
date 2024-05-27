//
//  OfferCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.11.2022.
//

import UIKit

class OfferCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var offerView: OfferView!
    
    func setCell(offer: Offer, addToFav: (() -> Void)?, viewOffers: (() -> Void)?, showUsers: (() -> Void)?) {
        offerView.setView(offer: offer, addToFav: addToFav, viewOffers: viewOffers, showUsers: showUsers)
    }
}
