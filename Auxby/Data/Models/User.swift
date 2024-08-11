import Foundation

class User: Codable {
    
    // MARK: - Public properties
    var lastName: String
    var firstName: String
    var email: String
    var address = Address()
    var phone: String
    var avatar: String?
    var availableCoins: Int
    var isGoogleAccount: Bool
    var isSubscribedToNewsletter: Bool
    var rating: Int
    static let noProfilePhoto = "NoProfilePhoto"
    
    init() {
        lastName = ""
        firstName = ""
        email = ""
        phone = ""
        isGoogleAccount = false
        isSubscribedToNewsletter = true
        availableCoins = 0
        rating = 5
    }
}

class UserResponsRegister: Codable {
    
    // MARK: - Public properties
    var lastName: String?
    var firstName: String?
    var email: String?
    var phone: String?
    var avatar: String?
    var availableCoins: Int?
    var isGoogleAccount: Bool?
    static let noProfilePhoto = "NoProfilePhoto"
    
    init() {
        lastName = ""
        firstName = ""
        email = ""
        phone = ""
        isGoogleAccount = false
        availableCoins = 0
    }
}

class Address: Codable {
    var city: String
    var country: String
    
    init() {
        city = ""
        country = ""
    }
}
