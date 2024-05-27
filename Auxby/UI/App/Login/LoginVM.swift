//
//  LoginVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import Foundation
import Combine

class LoginVM: ObservableObject {
    // MARK: - Public properties
    var email: String?
    var password: String?
    var isFromObording = false
    var hasAgreed = false
    var needToPop = 1
    var supplimentarAction: (()-> Void)?
    
    @Published private(set) var loginState = RequestState<LoginResponse>.idle
    @Published private(set) var getUserState = RequestState<User>.idle
    @Published private(set) var getSaveApnsState = RequestState<Void>.idle
    @Published private(set) var loginGoogleState = RequestState<LoginResponse>.idle
    var cancellables: Set<AnyCancellable> = []
    
    func login() {
        loginState = .loading
        guard let email = email, let pass = password,
        !email.isEmpty, !pass.isEmpty else {
            loginState = .failed("Email and password not found")
            return
        }
        let request: ApiRequest = .login(email: email, pass: pass)
        Network.shared.request(endpoint: request)
            .assign(to: &$loginState)
    }
    
    func loginGoogle(token: String) {
        loginGoogleState = .loading
        Network.shared.request(endpoint: .loginGoogle(token: token))
            .assign(to: &$loginGoogleState)
    }
    
    func getUser() {
        getUserState = .loading
        Network.shared.request(endpoint: .getUser)
            .assign(to: &$getUserState)
    }
    
    func saveApns() {
        getSaveApnsState = .loading
        Network.shared.voidRequest(endpoint: .saveApnsToken)
            .assign(to: &$getSaveApnsState)
    }
}
