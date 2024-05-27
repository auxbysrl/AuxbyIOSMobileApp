//
//  DetailsCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 11.01.2023.
//

import UIKit

class DetailsCell: UIView {

   
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    func setCell(title: String, content: String){
        titleLabel.text = title
        contentLabel.text = content
    }
    
}
