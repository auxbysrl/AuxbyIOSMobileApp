//
//  InputFieldView.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import UIKit
import Combine

class InputFieldView: UIView, InputValidationProtocol, NewOfferValue {
    
    // MARK: - IBOutlets
    @IBOutlet private var defaultView: UIView!
    @IBOutlet private var textField: UITextField!
    @IBOutlet private weak var label: UILabel!
    
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var separator: UIView!
    @IBOutlet private weak var showPassword: UIButton!
    @IBOutlet private weak var errorLabelHeight: NSLayoutConstraint!
    
    // A publisher that you can use to observe the input text changes
    lazy var textPublisher = textField.textPublisher
    private(set) var type: InputValidator!
    var text: String { textField.text ?? "" }
    var value: NewOffer.Values = NewOffer.Values(key: "", value: "")
    
    // Returns if the input text is valid
    private(set) var isValid = false
    var endEditing: (() -> Void)?
    var shouldUseDatePicker: Bool = false
    var title: String = "" {
        didSet {
            label.text = title
        }
    }
    
    // MARK: - Private properties
    private var cancellables: Set<AnyCancellable> = []
    // Closure called when the next keyboard button is pressed
    private var keyboardNextAction: (() -> Void)?
    private var canBeEmpty = false
    private var datePicker = UIDatePicker()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    // MARK: - IBActions
    @IBAction func textFieldInputChanged(_ sender: UITextField) {
        if sender.isSecureTextEntry {
            showPassword.isHidden = sender.text?.isEmpty == true
            separator.isHidden = sender.text?.isEmpty == true
        }
        if !shouldUseDatePicker {
            if !canBeEmpty { inputIsValid() }
        }
    }
    
    @IBAction private func shorOrHide(_ sender: UIButton) {
        textField.isSecureTextEntry.toggle()
        let image = textField.isSecureTextEntry ? "eye" : "eye.slash"
        showPassword.setImage(UIImage(systemName: image), for: .normal)
    }
    
    // MARK: - Public methods
    func set(type: InputValidator,
             text: String? = "",
             canBeEmpty: Bool = false,
             hideError: Bool = false,
             placeholder: String? = nil,
             shouldBeUpper: Bool = false,
             returnKey: UIReturnKeyType = .default,
             keyboardNextAction: (() -> Void)? = nil, textSize: Int? = nil) {
        
        if shouldUseDatePicker {
            createDatePicker()
        }
        
        self.type = type
        self.canBeEmpty = canBeEmpty
        self.keyboardNextAction = keyboardNextAction
        label.text = type.title
        textField.text = text
        if shouldBeUpper {
            textField.autocapitalizationType = .sentences
        }
        textField.returnKeyType = returnKey
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.textLight]
        )
        textField.keyboardType = type.keyboardType
        isValid = InputValidator.isValid(type: type, text: text).isValid
        errorLabel.isHidden = hideError
        errorLabelHeight.constant = hideError ? 0 : 22
        if case .password = type {
            textField.isSecureTextEntry = true
        }
        
        if let size = textSize {
            label.font = label.font.withSize(CGFloat(size))
            textField.font = textField.font?.withSize(CGFloat(size))
        }
    }
    
    func setText(text: String) {
        textField.text = text
    }
    
    /// Keyboard focus on the input field
    func focus() {
        textField.becomeFirstResponder()
    }
    
    func clearFocus() {
        textField.endEditing(true)
    }
    
    /// Use this method to set the view as uneditable view, like for the primary e-mail fied that cannot be changed
    func setUneditableState() {
        isUserInteractionEnabled = false
        textField.textColor = .lightGray
    }
    
    /// Check if the input is valid and color the view accordingly to the input text
    func inputIsValid() {
        if type == nil { return }
        let (isValid, error) = InputValidator.isValid(type: type, text: textField.text)
        textField.layer.borderColor = (isValid ? UIColor .primaryLight : .red).cgColor
        errorLabel.text = error
        self.isValid = isValid
    }
    
    func setInvalid(message: String) {
        let color: UIColor = .red
        textField.layer.borderColor = color.cgColor
        errorLabel.text = message
        isValid = false
    }
}

// MARK: - Private methods
private extension InputFieldView {
    func setView() {
        Bundle.main.loadNibNamed("InputField", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
        // observe the text changing
        textPublisher.sink { [unowned self] text in
            let (isValid, _) = InputValidator.isValid(type: type, text: textField.text)
            self.isValid = isValid
        }.store(in: &cancellables)
    }
}

extension InputFieldView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            keyboardNextAction?()
        }
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // when the input text end editing, check if it is valid
        value.value = textField.text ?? ""
        if !shouldUseDatePicker {
            if !canBeEmpty { inputIsValid() }
        }
        endEditing?()
    }
}

extension InputFieldView {
    fileprivate func createDatePicker() {
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(donePressed), for: .valueChanged)
        if let maximumDate = Calendar.current.date(byAdding: .day, value: 90, to: Date() + 1 ) {
            datePicker.maximumDate = maximumDate
            datePicker.minimumDate = Date() + 1
        }
        textField.inputView = datePicker
    }
    
    @objc func donePressed() {
        if datePicker.date <= Date() + 1 {
            textField.text = ""
            setInvalid(message: "addOffer_past_date".l10n())
            self.endEditing(true)
        } else {
            let dateFromatter = DateFormatter()
            dateFromatter.dateFormat = "dd MMMM YYYY"
            textField.text = dateFromatter.string(from: datePicker.date)
            inputIsValid()
            endEditing?()
            self.endEditing(true)
        }
    }
}
