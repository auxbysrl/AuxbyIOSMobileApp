//
//  RegisterVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.10.2022.
//

import Foundation
import Combine

class RegisterVM {
    // MARK: - Public properties
    var user = User()
    var password: String?
    var confirmedPassword: String?
    var needToPop = 1
    var isFromOmbording = false
    var hasAgreed = false
    
    @Published private(set) var registerState = RequestState<UserResponsRegister>.idle
    @Published private(set) var checkEmailState = RequestState<Bool>.idle
    
    var cancellables: Set<AnyCancellable> = []
    
    init(needToPop: Int = 1 , isFromOmboarding: Bool = false) {
        self.needToPop = needToPop
        self.isFromOmbording = isFromOmboarding
    }
    
    func register() {
        registerState = .loading
        Network.shared.request(endpoint: .create(user: user, pass: password!)).assign(to: &$registerState)
    }
    
    func checkEmail() {
        checkEmailState = .loading
        let request: ApiRequest = .checkEmail(email: user.email)
        Network.shared.request(endpoint: request)
            .assign(to: &$checkEmailState)
    }
}
