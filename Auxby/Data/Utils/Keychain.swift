//
//  Keychain.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.10.2022.
//

import Security
import UIKit

enum KeychainItem: String, CaseIterable {
    case token
    case email
}

class Keychain {
    
    /// Save a KeychainItem to the system key chain
    class func save(value: String, item: KeychainItem) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: item.rawValue,
            kSecValueData as String: Data(value.utf8)
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    /// Get a KeychainItem from the system key chain
    class func get(_ item: KeychainItem) -> String? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: item.rawValue,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        
        return nil
    }
    
    /// Delete a KeychainItem from the system key chain
    class func delete(_ item: KeychainItem) {
        let query = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrAccount as String: item.rawValue
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
    }
    
    /// Delete all Keychain Items from the system key chain
    class func deleteAll() {
        KeychainItem.allCases.forEach { key in
            delete(key)
        }
    }
}
