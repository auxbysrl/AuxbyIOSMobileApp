//
//  Offline.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Foundation
import L10n_swift

enum OfflineKey {
    
    case categories, offers, language, onboardingSeen, categoryDetails, favorites
    case currentUser, userOffers, userBids, shouldReloadProfilePicture, currentSearch
    case notifications, isNoInternetPresented, filteredOffers, readedChats, apnsToken, promotedOffers
    case currencies, offerIdFromURL, currentAdd, referralId
    
    // The key used to store offline the associated object
    var key: String {
        switch self {
        default: return String(describing: self) // returns the enum case name
        }
    }
}

extension Offline {
    /// Return the current logged in user
    static var currentUser: User? {
        Offline.decode(key: .currentUser, type: User.self)
    }
    
    static var counties = ["Alba",
                    "Arad",
                    "Arges",
                    "Bacau",
                    "Bihor",
                    "Bistrita - Nasaud",
                    "Botosani",
                    "Braila",
                    "Brasov",
                    "Bucuresti",
                    "Buzau",
                    "Calarasi",
                    "Caras - Severin",
                    "Cluj",
                    "Constanta",
                    "Covasna",
                    "Dambovita",
                    "Dolj",
                    "Galati",
                    "Giurgiu",
                    "Gorj",
                    "Harghita",
                    "Hunedoara",
                    "Ialomita",
                    "Iasi",
                    "Ilfov",
                    "Maramures",
                    "Mehedinti",
                    "Mures",
                    "Neamt",
                    "Olt",
                    "Prahova",
                    "Salaj",
                    "Satu Mare",
                    "Sibiu",
                    "Suceava",
                    "Teleorman",
                    "Timis",
                    "Tulcea",
                    "Valcea",
                    "Vaslui",
                    "Vrancea"]
    
    static var languages = ["en", "ro"]
}

/// A helper class that handles the encoding/decoding of the Encodable/Decodable objects
final class Offline {
    /// Encode and store an object and its subobjects that conforms to the Encodable protocol
    class func encode<T: Encodable>(_ value: T, key: OfflineKey) {
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.standard.set(data, forKey: key.key)
        } catch {
            print("Unable to encode the provided object: (\(error))")
        }
    }
    
    /// Decode an object and its subobjets that conforms to the Decodable protocol
    class func decode<T: Decodable>(key: OfflineKey, type: T.Type) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.key) else {
            return nil
        }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Unable to decode the object with offlineKey: \(key.key)")
        }
        return nil
    }
    
    /// Remove an offline saved object and its subobjects identified by the provided key
    class func delete(key: OfflineKey) {
        UserDefaults.standard.removeObject(forKey: key.key)
    }
}
