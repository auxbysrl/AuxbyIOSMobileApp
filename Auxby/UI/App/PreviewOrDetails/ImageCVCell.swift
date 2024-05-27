//
//  ImageCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 10.01.2023.
//

import UIKit

class ImageCVCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    func setCell(image: String? = nil, newImage: UIImage? = nil) {
        if image == nil {
            imageView.image = UIImage(named: "noPhotoImage")
        } else {
            imageView.setImage(from: image!, reload: false)
        }
        if newImage != nil {
            imageView.image = newImage
        }
    }
}
