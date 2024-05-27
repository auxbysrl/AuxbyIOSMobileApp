//
//  DropDownWithTextInput.swift
//  Auxby
//
//  Created by Andrei Traciu on 16.01.2023.
//

import UIKit
import Combine
import DropDown
import L10n_swift

// Recommended height to use is 74, or with error label 96
class DropDownWithTextInput: UIView, InputValidationProtocol {
    
    // MARK: IBOutlets
    @IBOutlet weak var defaultView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var rightLbl: UILabel!
    @IBOutlet weak var dropdownBtn: UIButton!
    
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var errorLblHeight: NSLayoutConstraint!
    
    // MARK: Public Properties
    // A publisher that you can use to observe the input text changes
    lazy var textPublisher = inputField.textPublisher
    var startEditingDropdown: (() -> Void)?
    var endEditing: (() -> Void)?
    var actionAfterSet: (() -> Void)?
    let dropDown = DropDown()
    var text: String { inputField.text ?? "" }
    var selectedDropdownOption: String { rightLbl.text ?? "" }
    
    // MARK: Private Properties
    private(set) var type: InputValidator!
    private(set) var isValid = false
    private var canBeEmpty = false
    private var keyboardNextAction: (() -> Void)?
    private var cancellables: Set<AnyCancellable> = []
    
    private var titleStartTextSpaces: Int = 0
    private var titleStartEmptySpaces: String {
        Array(repeating: " ", count: titleStartTextSpaces).joined()
    }
    
    // MARK: Overriden Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    // MARK: IBActions
    @IBAction func dropdownAction(_ sender: Any) {
        showDropDown()
    }
    
    // MARK: Public Methods
    func setupInputField(title: String,
               type: InputValidator,
               inputText: String,
               placeholder: String? = nil,
               canBeEmpty: Bool = false,
               hideError: Bool = false,
               returnKey: UIReturnKeyType = .default,
               keyboardNextAction: (() -> Void)? = nil, textSize: Int? = nil) {
        
        titleLbl.text = title
        self.type = type
        self.canBeEmpty = canBeEmpty
        self.keyboardNextAction = keyboardNextAction
        
        inputField.delegate = self
        inputField.text = inputText
        inputField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textLight]
        )
        inputField.keyboardType = type.keyboardType
        isValid = InputValidator.isValid(type: type,
                                         text: inputText).isValid
        errorLbl.isHidden = hideError
        errorLblHeight.constant = hideError ? 0 : 22
    }
    
    func setupDropdown(dataSource: [String], selectedIndex: Int = 0) {
        dropDown.dataSource = dataSource
        if !dataSource.isEmpty && selectedIndex < dataSource.count {
            dropDown.selectRow(selectedIndex)
            rightLbl.text = dataSource[selectedIndex]
        }
    }
    
    /// Keyboard focus on the input field
    func focus() {
        inputField.becomeFirstResponder()
    }
    
    func clearFocus() {
        inputField.endEditing(true)
    }
    
    /// Check if the input is valid and color the view accordingly to the input text
    func inputIsValid() {
        if type == nil { return }
        let (isValid, error) = InputValidator.isValid(type: type, text: inputField.text)
        borderView.layer.borderColor = (isValid ? UIColor .primaryLight : .red).cgColor
        errorLbl.text = error
        self.isValid = isValid
    }
    
    func setInvalid(message: String) {
        let color: UIColor = .red
        inputField.layer.borderColor = color.cgColor
        errorLbl.text = message
        isValid = false
    }
    
    // MARK: Private Methods
}

// MARK: - Private methods
private extension DropDownWithTextInput {
    func setView() {
        Bundle.main.loadNibNamed("DropDownWithTextInput", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
        // observe the text changing
        textPublisher.sink { [unowned self] text in
            let (isValid, _) = InputValidator.isValid(type: type, text: inputField.text)
            self.isValid = isValid
        }.store(in: &cancellables)
        
        delay(0.5) { // a short delay until the view is fully rendered
            self.setDropDown()
        }
    }
}

extension DropDownWithTextInput: UITextFieldDelegate {
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            keyboardNextAction?()
        }
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // when the input text end editing, check if it is valid
        if !canBeEmpty { inputIsValid() }
        endEditing?()
    }
}

private extension DropDownWithTextInput {
    @objc func showDropDown() {
        dropDown.anchorView = dropdownBtn
        dropDown.bottomOffset = CGPoint(x: 0, y: dropdownBtn.frame.height)
        dropDown.width = dropdownBtn.frame.width
        dropDown.show()
        startEditingDropdown?()
    }
    
    func setDropDown() {
        dropDown.anchorView = dropdownBtn
        dropDown.width = dropdownBtn.frame.width
        dropDown.textColor = .primaryLight
        dropDown.selectedTextColor = .white
        dropDown.textFont = .systemFont(ofSize: isPad ? 18 : 14)
        dropDown.selectionBackgroundColor = .primaryLight
        dropDown.backgroundColor = .white
        dropDown.setupCornerRadius(8)
        dropDown.bottomOffset = CGPoint(x: 0, y: dropdownBtn.frame.height)
        // selection action handler
        dropDown.selectionAction = { [unowned self] _, item in
            let lang = titleStartEmptySpaces + item
            rightLbl.text = lang
            actionAfterSet?()
        }
    }
}
