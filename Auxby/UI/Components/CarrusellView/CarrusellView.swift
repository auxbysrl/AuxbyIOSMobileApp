//
//  CarruselView.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.02.2023.
//

import UIKit
import L10n_swift

class CarrusellView: UIView {

    @IBOutlet var defaultView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var priceType: UILabel!
    @IBOutlet weak var promotedView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    func set(offer: Offer) {
        titleLabel.text = offer.title
        descriptionLabel.text = offer.description
        promotedView.isHidden = !offer.isPromoted
        if offer.photos!.isEmpty {
            offerImage.image = UIImage(named: "noPhotoImage")
        } else {
            offerImage.setImage(from: offer.photos![0].url!)
        }
        var price = 0
        if offer.isOnAuction {
            priceType.text = "currentBid".l10n()
            price = offer.highestBid == 0 ? Int(offer.price) : Int(offer.highestBid!)
        } else {
            priceType.text = "price".l10n()
            price = Int(offer.price)
        }
        priceLabel.text = "\(price.formattedString) " + (offer.currencySymbol ?? "")
    }

}
private extension CarrusellView {
    func setView() {
        Bundle.main.loadNibNamed("CarrusellView", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}
