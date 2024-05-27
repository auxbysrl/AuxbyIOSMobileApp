//
//  BuyCoinsVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 09.05.2024.
//

import Foundation
import Combine
import StoreKit
class BuyCoinsVM {
    var selectedBundle: Int? = 1
    var products: [SKProduct] = []
    @Published private(set) var getTransactionStatus = RequestState<Void>.idle
    @Published private(set) var getUserState = RequestState<User>.idle
    var cancellables: Set<AnyCancellable> = []
    
    func finishTransaction(product: SKProduct) {
        getTransactionStatus = .loading
        Network.shared.voidRequest(endpoint: .finishTransaction(coins: "\(product.numberOfCoins ?? 0)", price: "\(product.price)", productName: "Auxby " + (product.title ?? "") + " pack"))
            .assign(to: &$getTransactionStatus)
    }
    
    func getUser() {
        getUserState = .loading
        Network.shared.request(endpoint: .getUser)
            .assign(to: &$getUserState)
    }
}
