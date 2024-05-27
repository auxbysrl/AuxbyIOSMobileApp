//
//  AlertView.swift
//  Auxby
//
//  Created by Eduard Hutu on 02.03.2023.
//

import UIKit

class AlertView: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    @IBOutlet private weak var coinImage: UIImageView!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private var defaultView: UIView!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var contentDeleteLabel: UILabel!
    @IBOutlet weak var titleDeleteLabel: UILabel!
    @IBOutlet weak var normalView: UIView!
    @IBOutlet weak var deleteView: UIView!
    
    
    var confirm: (() -> Void)?
    var cancel: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
   
    func set(title: String, content: String, secondButtonTitle: String) {
        deleteView.isHidden = true
        normalView.isHidden = false
        coinImage.isHidden = false
        imageWidth.constant = 20
        titleLabel.text = title
        titleLabel.textColor = .textDark
        contentLabel.text = content
        contentLabel.textColor = .secondary
        confirmButton.setTitle(secondButtonTitle, for: .normal)
        confirmButton.backgroundColor = .primaryLight
    }
    
    func setNoImage(title: String, content: String, secondButtonTitle: String) {
        coinImage.isHidden = true
        imageWidth.constant = 0
        titleLabel.text = title
        contentLabel.text = content
        contentLabel.textColor = UIColor.textDark
        confirmButton.setTitle(secondButtonTitle, for: .normal)
    }
    
    func setDelete(title: String, content: String, secondButtonTitle: String) {
        normalView.isHidden = true
        deleteView.isHidden = false
        titleDeleteLabel.text = title
        contentDeleteLabel.text = content
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        cancel?()
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        confirm?()
    }
}
private extension AlertView {
    func setView() {
        Bundle.main.loadNibNamed("AlertView", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}
