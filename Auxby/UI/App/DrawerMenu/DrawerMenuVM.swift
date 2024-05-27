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
    var cancellables: Set<AnyCancellable> = []
    
    func getUsersOffers() {
        getUserOffers = .loading
        Network.shared.request(endpoint: .getUserOffers)
            .assign(to: &$getUserOffers)
    }
}
