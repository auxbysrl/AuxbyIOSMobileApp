//
//  TextViewInput.swift
//  Auxby
//
//  Created by Andrei Traciu on 17.01.2023.
//

import UIKit
import Combine

class TextViewInput: UIView, InputValidationProtocol {
    
    // MARK: IBOutlets
    @IBOutlet var defaultView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var textInputView: UITextView!
    @IBOutlet var errorLbl: UILabel!
    
    // MARK: Public Properties
    // A publisher that you can use to observe the input text changes
    lazy var textPublisher = textInputView.textPublisher
    private(set) var type: InputValidator!
    
    // MARK: Private Properties
    private var cancellables: Set<AnyCancellable> = []
    // Closure called when the next keyboard button is pressed
    private var keyboardNextAction: (() -> Void)?
    private var canBeEmpty = false
    
    // Returns if the input text is valid
    private(set) var isValid = false
    var endEditing: (() -> Void)?
    var text: String { textInputView.text ?? "" }
    
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
    
    // MARK: Public Methods
    func setup(type: InputValidator,
             text: String? = nil,
             canBeEmpty: Bool = false,
             hideError: Bool = false,
             returnKey: UIReturnKeyType = .default,
             keyboardNextAction: (() -> Void)? = nil) {
        
        textInputView.delegate = self
        self.type = type
        self.canBeEmpty = canBeEmpty
        self.keyboardNextAction = keyboardNextAction
        titleLbl.text = type.title
        textInputView.text = text
        textInputView.returnKeyType = returnKey
        textInputView.keyboardType = type.keyboardType
        isValid = InputValidator.isValid(type: type, text: text).isValid
        errorLbl.isHidden = hideError
        errorLbl.alpha = hideError ? 0 : 1
        if case .password = type {
            textInputView.isSecureTextEntry = true
        }
    }
    
    /// Check if the input is valid and color the view accordingly to the input text
    func inputIsValid() {
        if type == nil { return }
        let (isValid, error) = InputValidator.isValid(type: type, text: textInputView.text)
        textInputView.layer.borderColor = (isValid ? UIColor .primaryLight : .red).cgColor
        errorLbl.text = error
        self.isValid = isValid
    }
    
    func setInvalid(message: String) {
        let color: UIColor = .red
        textInputView.layer.borderColor = color.cgColor
        errorLbl.text = message
        isValid = false
    }
    
    // MARK: Private Methods
}

// MARK: - Private methods
private extension TextViewInput {
    func setView() {
        Bundle.main.loadNibNamed("TextViewInput", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
        // observe the text changing
        textPublisher.sink { [unowned self] text in
            let (isValid, _) = InputValidator.isValid(type: type, text: textInputView.text)
            self.isValid = isValid
        }.store(in: &cancellables)
    }
}

extension TextViewInput: UITextViewDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .next {
            keyboardNextAction?()
        }
        textField.endEditing(true)
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        // when the input text end editing, check if it is valid
        if !canBeEmpty { inputIsValid() }
        endEditing?()
    }
}
