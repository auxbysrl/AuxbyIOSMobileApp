//
//  DrawerMenuVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 28.03.2023.
//

import Foundation
import Combine

class DrawerMenuVM {
    @Published private(set) var getUserOffers = RequestState<[Offer]>.idle
    @Published private(set) var getDeleteUser = RequestState<Void>.idle
    @Published private(set) var getLogoutState = RequestState<Void>.idle
    var cancellables: Set<AnyCancellable> = []
    
    func getUsersOffers() {
        getUserOffers = .loading
        Network.shared.request(endpoint: .getUserOffers)
            .assign(to: &$getUserOffers)
    }
    
    func deleteUser() {
        getDeleteUser = .loading
        Network.shared.voidRequest(endpoint: .delete)
            .assign(to: &$getDeleteUser)
    }
    
    func logout() {
        getLogoutState = .loading
        Network.shared.voidRequest(endpoint: .logout)
            .assign(to: &$getLogoutState)
    }
}
