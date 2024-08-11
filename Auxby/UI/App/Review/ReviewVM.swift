//
//  ReviewVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 13.03.2023.
//

import Foundation
import Combine

class ReviewVM {
    var rating: Int = 1
    var userName: String
    
    @Published private(set) var getRatingState = RequestState<Void>.idle
    var cancellables: Set<AnyCancellable> = []
    
    init(userName: String) {
        self.userName = userName
    }
    
    func rateUser() {
        getRatingState = .loading
        Network.shared.voidRequest(endpoint: .rateUser(userName: userName, rating: rating))
            .assign(to: &$getRatingState)
    }
    
}
