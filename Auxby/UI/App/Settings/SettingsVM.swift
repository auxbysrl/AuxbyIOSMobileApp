//
//  SettingsVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.12.2022.
//

import Foundation
import Combine

class SettingsVM {
    
    // MARK: - Public properties
    var isEditing = false
    var user: User = User()
    @Published private(set) var getChangeSubscriptionState = RequestState<SuccessResponseBool>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init() {
        if let user = Offline.decode(key: .currentUser, type: User.self) {
            self.user = user
        }
    }
    
    func changeSubscription() {
        getChangeSubscriptionState = .loading
        Network.shared.request(endpoint: .changeSubscriptionStatus)
            .assign(to: &$getChangeSubscriptionState)
    }
    
}
