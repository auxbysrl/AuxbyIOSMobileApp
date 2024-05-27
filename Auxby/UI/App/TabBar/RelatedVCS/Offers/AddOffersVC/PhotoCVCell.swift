//
//  PhotoCVCell.swift
//  Auxby
//
//  Created by Andrei Traciu on 17.01.2023.
//

import UIKit

class PhotoCVCell: UICollectionViewCell {
    
    enum PhotoCellState {
        case addPhoto
        case cover
        case simple
    }
    
    static let identifier = "PhotoCVCell"
    
    // MARK: IBOutlets
    @IBOutlet var photoImageView: UIImageView!
    
    // MARK: Public Properties
    var state: PhotoCellState = .addPhoto
    
    // MARK: Private Properties
    
    // MARK: Overriden Methods
    
    // MARK: IBActions
    
    // MARK: Public Methods
    func setState(photoState: PhotoCellState, imageToUse: UIImage?) {
        switch photoState {
        case .addPhoto:
            setAddPhotoUI()
        case .cover:
            setup(withImage: imageToUse ?? UIImage())
            contentView.borderWidth = 2
            contentView.borderColor = .secondary
        default:
            setup(withImage: imageToUse ?? UIImage())
            contentView.borderWidth = 0
        }
    }
    
    func setup(withImage newImage: UIImage) {
        contentView.cornerRadius = 10
        photoImageView.image = newImage
    }
    
    func setAddPhotoUI() {
        contentView.cornerRadius = 10
        contentView.borderColor = .primaryLight
        contentView.borderWidth = 1
        photoImageView.image = UIImage(named: "addPlus")
    }
    

    // MARK: Private Methods
}
