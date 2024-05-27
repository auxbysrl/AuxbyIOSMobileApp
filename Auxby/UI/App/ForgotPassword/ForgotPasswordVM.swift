//
//  ForgotPasswordVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.11.2022.
//

import Foundation
import Combine

class ForgotPasswordVM {
    
    var email: String?
    
    // MARK: - Public properties
    @Published private(set) var forgotPasswordState = RequestState<Void>.idle
    var cancellables: Set<AnyCancellable> = []
    
    func forgotPassword() {
        Network.shared.voidRequest(endpoint: .forgotPassword(email: email ?? ""))
            .assign(to: &$forgotPasswordState)
    }
    
}
