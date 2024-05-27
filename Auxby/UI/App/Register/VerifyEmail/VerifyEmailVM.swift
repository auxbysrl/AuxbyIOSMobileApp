//
//  VerifyEmailVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.11.2022.
//

import Foundation
import Combine

class VerifyEmailVM {
    
    // MARK: - Public properties
    var email: String
    var password: String
    var neetToPop: Int
    @Published private(set) var loginState = RequestState<LoginResponse>.idle
    @Published private(set) var resendEmailState = RequestState<Void>.idle
    @Published private(set) var getSaveApnsState = RequestState<Void>.idle
    @Published private(set) var getUserState = RequestState<User>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(email: String, password: String, needToPop: Int = 0) {
        self.email = email
        self.password = password
        self.neetToPop = needToPop
    }
    
    func login(email: String, password: String) {
        loginState = .loading
        let request: ApiRequest = .login(email: email, pass: password)
        Network.shared.request(endpoint: request)
            .assign(to: &$loginState)
    }
    
    func resendEmail() {
        resendEmailState = .loading
        let request: ApiRequest = .resendLink(email: email)
        Network.shared.voidRequest(endpoint: request)
            .assign(to: &$resendEmailState)
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
