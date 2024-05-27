//
//  InputValidator.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import UIKit
import L10n_swift

/// Use this protocol whenever a view should be validated if the input is valid
protocol InputValidationProtocol: UIView {
    var type: InputValidator! { get }
    var isValid: Bool { get }
}

extension InputValidationProtocol {
    // type from InputValidationProtocol is optional
    var type: InputValidator! { nil }
}

enum InputValidator: Equatable{
    enum PasswordType {
        case password, current, new, confirm, newChangePassword, notEmpty
        var name: String {
            switch self {
            case .password: return "password".l10n()
            case .current: return "currentPassword".l10n()
            case .new: return "newPassword".l10n()
            case .confirm: return "confirmPassword".l10n()
            case .newChangePassword: return "newPassword".l10n()
            case .notEmpty: return "cannotBeEmpty".l10n()
            }
        }
    }
    
    case email
    case password(PasswordType)
    case phoneNumber
    case stringNamed(String)
    case intNamed(String)
    case doubleNamed(String)
    case notEmpty
    case sentanceNamed(String)
    
    var title: String {
        switch self {
        case .email: return "email".l10n()
        case .password(let type): return type.name
        case .phoneNumber: return "phoneNumber".l10n()
        case .stringNamed(let name), .intNamed(let name), .doubleNamed(let name), .sentanceNamed(let name):
            return name
        case .notEmpty: return ""
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .email:
            return .emailAddress
        case .phoneNumber:
            return .numbersAndPunctuation
        case .intNamed:
            return .numberPad
        case .doubleNamed:
            return .numberPad
        default: return .default
        }
    }
    
    static func isValid(type: Self, text: String?) -> (isValid: Bool, error: String?) {
        switch type {
        case .email: return emailIsValid(text)
        case .password(let type): return passwordIsValid(text, type: type)
        case .phoneNumber: return phoneIsValid(text)
        case .stringNamed: return stringInputIsValid(text: text)
        case .intNamed: return integerInputIsValid(text: text)
        case .doubleNamed: return doubleInputIsValid(text: text)
        case .notEmpty: return stringInputIsEmpty(text: text)
        case .sentanceNamed: return sentaceInputIsValid(text: text)
        }
    }
}

private extension InputValidator {
    static func emailIsValid(_ email: String?) -> (isValid: Bool, error: String?) {
        if email?.isEmpty == true {
            return (false, "cannotBeEmpty".l10n())
        }
        
        if email?.isEmpty == false, email?.isEmail == false {
            return (false, "invalidEmailFormat".l10n())
        }
        
        return (true, nil)
    }
    
    static func passwordIsValid(_ pass: String?, type: PasswordType) -> (isValid: Bool, error: String?) {
        if pass?.isEmpty == true {
            return (false, "cannotBeEmpty".l10n())
        }
        
        switch type {
        case .password:
            // login password check
            if pass?.isValidPassword == false {
                return (false, "invalidPassword".l10n())
            }
        case .current:
            if pass?.isValidPassword == false {
                return (false, "invalidPasswordFormat".l10n())
            }
        case .confirm:
            if pass?.isValidPassword == false {
                return (false, "invalidPasswordFormat".l10n())
            }
        case .newChangePassword:
            if pass?.isValidPassword == false {
                return (false, "invalidPasswordFormat".l10n())
            }
        case .new:
            if pass?.isValidPassword == false {
                return (false, "invalidPasswordFormat".l10n())
            }
        default:
            return (true, nil)
        }
        
        return (true, nil)
    }
    
    static func phoneIsValid(_ phone: String?) -> (isValid: Bool, error: String?) {
        if phone?.isEmpty == true {
            return (false, "cannotBeEmpty".l10n())
        }
        
        if phone?.count ?? 0 < 10 {
            return (false, "invalidPhone".l10n())
        }
        
        if phone?.isPhone == false {
            return (false, "invalidPhone".l10n())
        }
        return (true, nil)
    }
    
    
    static func stringInputIsValid(text: String?) -> (isValid: Bool, error: String?) {
        if text?.isEmpty == true {
            return (false, "cannotBeEmpty".l10n())
        }
        if text?.count ?? 0 < 2 {
            return (false, "invalidFormat".l10n())
        }
        if text?.containsOnlyLetters == false {
            return(false, "invalidFormat".l10n())
        }
        return (true, nil)
    }
    
    static func sentaceInputIsValid(text: String?) -> (isValid: Bool, error: String?) {
        if text?.isEmpty == true {
            return (false, "cannotBeEmpty".l10n())
        }
        if text?.count ?? 0 < 2 {
            return (false, "invalidFormat".l10n())
        }
        return (true, nil)
    }
    
    static func stringInputIsEmpty(text: String?) -> (isValid: Bool, error: String?) {
        if text?.isEmpty == true {
            return (false, "cannotBeEmpty".l10n())
        }
        return (true, nil)
    }
    
    static func integerInputIsValid(text: String?, canBeEmpty: Bool = false) -> (isValid: Bool, error: String?) {
        if text?.isEmpty == false {
            guard let int = Int(text ?? "") else {
                return (false, "invalidFormat".l10n())
            }
            if int <= 0 {
                return (false, "invalidFormat".l10n())
            }
        } else if !canBeEmpty {
            return (false, "cannotBeEmpty".l10n())
        }
        return (true, nil)
    }
    
    static func doubleInputIsValid(text: String?, canBeEmpty: Bool = false) -> (isValid: Bool, error: String?) {
        if text?.isEmpty == false {
            guard let double = Double(text ?? "") else {
                return (false, "invalidFormat".l10n())
            }
            if double <= 0 {
                return (false, "invalidFormat".l10n())
            }
        } else if !canBeEmpty {
            return (false, "cannotBeEmpty".l10n())
        }
        return (true, nil)
    }
}

extension Array where Element == InputValidationProtocol {
    /// Returns true if all the inputs are valid
    var areValid: Bool {
        allSatisfy { $0.isValid }
    }
}
