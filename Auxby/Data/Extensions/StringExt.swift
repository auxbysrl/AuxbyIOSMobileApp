//
//  StringExt.swift
//  NDSports
//
//  Created by Senocico Stelian on 19.01.2022.
//

import UIKit
import L10n_swift

/**
 Defined different symbols to be printed in the Xcode console depending of the network response.
 Used only in Network class to ease reading in the console.
 */
extension String {
    var consoleParameters: String { setTemplateWith(message: "SENT PARAMETERS", symbol: "🔵") }
    var consoleSuccessResponse: String { setTemplateWith(message: "SUCCESS RESPONSE", symbol: "✅") }
    var consoleAPIError: String { setTemplateWith(message: "API ERROR", symbol: "⛔️") }
    var consoleServerError: String { setTemplateWith(message: "SERVER ERROR", symbol: "❌") }
    var consoleError: String { setTemplateWith(message: "ERROR", symbol: "‼️") }
    
    private func setTemplateWith(message: String, symbol: String) -> String {
        "\(symbol) \(message) \(symbol)\n" + self + "\n"
    }
}

extension String {
    /// Check if this string is an email
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    /// Check if this string is a phone number
    var isPhone: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self)
    }
    
    /// Check if a string is a valid password format
    var isValidPassword: Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d\\S]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: self)
    }
    
    /// Try convert the JSON string to a dictionary
    var asDictionary: [String: Any]? {
        if let data = data(using: .utf8) {
            return try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        }
        return nil
    }
    
    /// Check if the string contains only letters
//    var containsOnlyLetters: Bool {
//        for chr in self {
//            if !(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") {
//                return false
//            }
//        }
//        return true
//    }
    
    var containsOnlyLetters: Bool {
        let allowedCharacters = CharacterSet.letters
        for chr in self.unicodeScalars {
            if !allowedCharacters.contains(chr) {
                return false
            }
        }
        return true
    }
    
    var getCurrency: String {
        switch self {
        case "EURO": return "€"
        default: return "lei"
        }
    }
    /// Try convert string to date by formatter
    func toDate(format: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
    
    func size(with font: UIFont = .systemFont(ofSize: isPad ? 19 : 14)) -> CGSize {
        let label = UILabel()
        label.font = .systemFont(ofSize: isPad ? 19 : 14)
        label.text = self
        label.sizeToFit()
        return CGSize(width: label.frame.size.width + 24, height: (isPad ? 40 : 32))
    }
    
    func parseToInt() -> Int? {
        Int(components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
    
    func getCountryCode() -> String {
        switch self {
        case "en".l10n(): return "en"
        case "ro".l10n(): return "ro"
        default: return ""
        }
    }
    
    func getCountryFromCode() -> String {
        switch self {
        case "en": return "en".l10n()
        case "ro": return "ro".l10n()
        default: return ""
        }
    }
    
    func convertToCustomDateFormat() -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
            if let date = dateFormatter.date(from: self) {
                dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
                return dateFormatter.string(from: date)
            }
            return nil
        }
}

// Create an Error from String
extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
