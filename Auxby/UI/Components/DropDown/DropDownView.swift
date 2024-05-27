//
//  DropDownView.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.12.2022.
//

import UIKit
import DropDown
import L10n_swift

class DropDownView: UIView, NewOfferValue {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var secondaryTextLabel: UILabel!
    @IBOutlet private var defaultView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    // MARK: - Public properties
    var selectedText: String? { textLabel.text?.trimmingCharacters(in: .whitespaces) }
    var startEditing: (() -> Void)?
    var doneEditing: (() -> Void)?
    let dropDown = DropDown()
    var value: NewOffer.Values = NewOffer.Values(key: "", value: "")
    var isLanguage = true
    
    // MARK: - Private properties
    private var titleStartTextSpaces: Int = 0
    private var titleStartEmptySpaces: String {
        Array(repeating: " ", count: titleStartTextSpaces).joined()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    func set(dataSource: [String], selectedIndex: Int? = nil, secondaryText: String? = nil, title: String = "") {
        setTitleLbl(newText: title)
        isLanguage = true
        titleStartTextSpaces = 0
        dropDown.dataSource = dataSource
        if let index = selectedIndex, dataSource.indices.contains(index) {
            textLabel.text = dataSource[index]
            secondaryTextLabel.text = secondaryText ?? dataSource[index].getCountryCode()
            dropDown.selectRow(index)
        }
    }
    
    func setText(index: Int) {
        textLabel.text = dropDown.dataSource[index]
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        dropDown.setupCornerRadius(radius)
    }
    
    func resetText() {
        textLabel.text = titleStartEmptySpaces + ""
    }
    
    func setDataSource(dataSource: [String], selectedIndex: Int? = nil, title: String = "", placeholder: String = "") {
        setTitleLbl(newText: title)
        dropDown.dataSource = dataSource
        isLanguage = false
        if selectedIndex != nil {
            if dataSource.indices.contains(selectedIndex!) {
                textLabel.textColor = .primaryLight
                textLabel.text = titleStartEmptySpaces + dataSource[selectedIndex!]
                dropDown.selectRow(selectedIndex!)
            }
        } else {
            textLabel.text = placeholder
            textLabel.textColor = .textLight
        }
    }
    
    /// Use this mehod to reset the dropdown
    func resetLayout() {
        setDropDown()
    }
    
    private func setTitleLbl(newText: String) {
        titleLbl.isHidden = newText.isEmpty
        titleLbl.text = newText
    }
}

private extension DropDownView {
    func setView() {
        Bundle.main.loadNibNamed("DropDownView", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
        delay(0.5) { // a short delay until the view is fully rendered
            self.setDropDown()
        }
        
        defaultView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDropDown)))
    }
    
    @objc func showDropDown() {
        dropDown.anchorView = defaultView
        dropDown.bottomOffset = CGPoint(x: 0, y: defaultView.frame.height)
        dropDown.width = defaultView.frame.width
        dropDown.show()
        startEditing?()
    }
    
    func setDropDown() {
        dropDown.anchorView = textLabel
        dropDown.width = defaultView.frame.width
        dropDown.textColor = .primaryLight
        dropDown.selectedTextColor = .white
        dropDown.textFont = .systemFont(ofSize: isPad ? 18 : 14)
        dropDown.selectionBackgroundColor = .primaryLight
        dropDown.backgroundColor = .white
        dropDown.setupCornerRadius(8)
        dropDown.bottomOffset = CGPoint(x: 0, y: textLabel.frame.height)
        // selection action handler
        dropDown.selectionAction = { [unowned self] _, item in
            let lang = titleStartEmptySpaces + item
            textLabel.textColor = .primaryLight
            textLabel.text = lang
            if isLanguage {
                secondaryTextLabel.text = lang.getCountryCode()
                Offline.encode(lang.getCountryCode(), key: .language)
                L10n.shared.language = lang.getCountryCode()
            } else {
                value.value = textLabel.text!
                doneEditing?()
            }
        }
    }
}

