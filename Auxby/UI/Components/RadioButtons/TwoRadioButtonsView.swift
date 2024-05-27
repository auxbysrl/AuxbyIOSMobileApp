//
//  RadioButtonsView.swift
//  Auxby
//
//  Created by Andrei Traciu on 11.01.2023.
//

import UIKit

class TwoRadioButtonsView: UIView, NewOfferValue {
    
    // MARK: IBOutlets
    @IBOutlet var defaultView: UIView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstCheckImg: UIImageView!
    @IBOutlet weak var firstLabel: UILabel!
    
    @IBOutlet weak var secondCheckImg: UIImageView!
    @IBOutlet weak var secondLabel: UILabel!
    
    // MARK: Public Properties
    var isFirstSelected = true {
        didSet {
            updateSelectedState()
        }
    }
    
    var isSecondSelected = false {
        didSet {
            updateSelectedState()
        }
    }
    
    var reloadData: (() -> Void)?
    
    var canBeBoth = false
    
    var selectedOption: String {
        return (isFirstSelected ? firstLabel.text : secondLabel.text) ?? ""
    } 
    
    var value: NewOffer.Values = NewOffer.Values(key: "", value: "")
    
    // MARK: Private Properties
    
    // MARK: Overriden Methods
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    // MARK: IBActions
    @IBAction func firstTapAction(_ sender: Any) {
        if !canBeBoth {
            if isFirstSelected { return }
            isFirstSelected = true
            updateSelectedState()
            value.value = firstLabel.text!
            reloadData?()
        } else {
            isFirstSelected.toggle()
            updateSelectedState()
            value.value = firstLabel.text!
            reloadData?()
        }
    }
    
    @IBAction func secondTapAction(_ sender: Any) {
        if !canBeBoth {
            if !isFirstSelected { return }
            isFirstSelected = false
            updateSelectedState()
            value.value = secondLabel.text!
            reloadData?()
        } else {
            isSecondSelected.toggle()
            updateSelectedState()
            value.value = secondLabel.text!
            reloadData?()
        }
    }
    
    // MARK: Public Methods
    func setup(sectionLabel: String, optionOne: String, optionTwo: String, isFirstSelected: Bool, canBeBoth: Bool = false, isSecondSelected: Bool = false) {
        titleLbl.text = sectionLabel
        firstLabel.text = optionOne
        secondLabel.text = optionTwo
        self.canBeBoth = canBeBoth
        self.isFirstSelected = isFirstSelected
        self.isSecondSelected = isSecondSelected
    }
    
    // MARK: Private Methods
    private func updateSelectedState() {
        if !canBeBoth {
            setImageCheckState(imageView: firstCheckImg,
                               isSelected: isFirstSelected)
            setImageCheckState(imageView: secondCheckImg,
                               isSelected: !isFirstSelected)
        } else {
            setImageCheckState(imageView: firstCheckImg,
                               isSelected: isFirstSelected)
            setImageCheckState(imageView: secondCheckImg,
                               isSelected: isSecondSelected)
        }
    }
    
    private func setImageCheckState(imageView: UIImageView, isSelected: Bool) {
        UIView.animate(withDuration: 0.3) {
            imageView.image = UIImage(named: isSelected ? "FilledCheck" : "EmptyCheck")
        }
    }
    
    private func setView() {
        Bundle.main.loadNibNamed("RadioButtonsView", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}
