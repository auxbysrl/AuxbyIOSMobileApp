//
//  BidCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.08.2023.
//

import UIKit

class BidCVCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var bidDate: UILabel!
    @IBOutlet weak var bidValue: UILabel!
    
    func setCell(bid: Bid, currencySymbol: String) {
        userName.text = bid.userName
        let price = Int(bid.bidValue)
        bidValue.text = "\(price.formattedString)\(currencySymbol)"
        if let url = bid.userAvatar {
            userImage.setImage(from: url)
        } else {
            userImage.image = UIImage(named: Owner.noProfilePhoto)
        }
        bidDate.text = bid.getActiveString()
    }
}
