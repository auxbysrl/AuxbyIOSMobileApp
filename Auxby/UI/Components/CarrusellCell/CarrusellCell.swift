//
//  CarrusellCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.02.2023.
//

import UIKit

class CarrusellCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var carruselView: CarrusellView!
    
    func setCell(offer: Offer) {
        carruselView.set(offer: offer)
    }
}
