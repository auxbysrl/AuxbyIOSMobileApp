//
//  ChangePasswordVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.12.2022.
//

import Foundation
import Combine

class ChangePasswordVM {
    @Published private(set) var getChangeStatus = RequestState<Bool>.idle
    var cancellables: Set<AnyCancellable> = []
    var oldPassword = ""
    var newPassword = ""
    var confirmPassword = ""
    
    func changePassword() {
        getChangeStatus = .loading
        Network.shared.request(endpoint: .changePassword(oldPassword: oldPassword, newPassword: newPassword))
            .assign(to: &$getChangeStatus)
    }
}
