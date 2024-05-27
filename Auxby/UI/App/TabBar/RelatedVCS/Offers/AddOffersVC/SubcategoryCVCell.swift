//
//  SubcategoryCVCell.swift
//  Auxby
//
//  Created by Andrei Traciu on 12.01.2023.
//

import UIKit

class SubcategoryCVCell: UICollectionViewCell {
    
    static let identifier = "SubcategoryCVCell"
    
    // MARK: IBOutlets
    @IBOutlet var categoryImgView: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var shadowView: UIView!
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    
    // MARK: Overriden Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        delay(0.05) {
            self.addCellShadow()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.updateViewSelectedState()
        }
    }
    
    // MARK: IBActions
    
    // MARK: Public Methods
    func setupView(title: String, image: String) {
        titleLbl.text = title
        var newImage = image
        newImage.removeFirst()
        let url = "https://" + ApiRequest.baseURL + newImage
        categoryImgView.setImage(from: url)
    }
    
    func setSelectedState(isSelected: Bool) {
        self.isSelected = isSelected
        updateViewSelectedState()
    }
    
    func updateViewSelectedState() {
        shadowView.cornerRadius = 8
        shadowView.borderWidth = isSelected ? 1 : 0
        shadowView.borderColor = isSelected ? .secondary : .clear
        addCellShadow()
    }
    
    // MARK: Private Methods
    func addCellShadow() {
        shadowView.layer.shadowColor = UIColor(red: 0.729, green: 0.749, blue: 0.808, alpha: 0.2).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 3)
        shadowView.layer.shadowRadius = 8
        shadowView.layer.masksToBounds = false
    }
}
