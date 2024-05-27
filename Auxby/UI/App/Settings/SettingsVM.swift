//
//  SettingsVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.12.2022.
//

import Foundation

class SettingsVM {
    
    // MARK: - Public properties
    var isEditing = false
    var user: User = User()
    
    init() {
        if let user = Offline.decode(key: .currentUser, type: User.self) {
            self.user = user
        }
    }
    
}
