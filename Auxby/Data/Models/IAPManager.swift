//
//  IAPManager.swift
//  Auxby
//
//  Created by Eduard Hutu on 08.05.2024.
//

import UIKit
import StoreKit

enum IAPManagerAlertType {
    case disabled
    case restored
    case purchased
    case failed
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .failed: return "Could not complete purchase process.\nPlease try again."
        }
    }
}
private let isTestFlight = Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

var appConfiguration: AppConfiguration {
  if isDebug {
    return .Debug
  } else if isTestFlight {
    return .TestFlight
  } else {
    return .AppStore
  }
}

enum AppConfiguration: String {
  case Debug
  case TestFlight
  case AppStore
}

var isDebug: Bool {
  #if DEBUG
  return true
  #else
  return false
  #endif
}

public typealias ProductId = String
class IAPManager: NSObject {
  static let shared = IAPManager()
    let silverID = "auxby.pack.silver"
    let goldID = "auxby.pack.gold"
    let diamondID = "auxby.pack.diamond"
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    fileprivate var pendingFetchProduct: String!
    var fetchAvailableProductsBlock : (([SKProduct]) -> Void)? = nil
    var purchaseStatusBlock: ((IAPManagerAlertType) -> Void)?
    public var purchasedProductIdentifiers = Set<ProductId>()
    var finishTransaction: (()->Void)?
    
    private func fetchAvailableProducts() {
        productsRequest.cancel()
        // Put here your IAP Products ID’s
        let productIdentifiers = NSSet(objects: silverID, goldID, diamondID)
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func initialize() {
           fetchAvailableProducts()
       }
    
    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments() }
        
    func purchaseMyProduct(productIdentifier: String) {
            if iapProducts.isEmpty {
                pendingFetchProduct = productIdentifier
                fetchAvailableProducts()
                return
            }
            
            if canMakePurchases() {
                for product in iapProducts {
                    if product.productIdentifier == productIdentifier {
                        let payment = SKPayment(product: product)
                        SKPaymentQueue.default().add(self)
                        SKPaymentQueue.default().add(payment)
                    }
                }
            } else {
                purchaseStatusBlock?(.disabled)
            }
        }
}

extension IAPManager: SKProductsRequestDelegate {
    // MARK: — REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive
    response:SKProductsResponse) {
        if response.products.count > 0 {
           iapProducts = response.products
            fetchAvailableProductsBlock?(response.products)
        }
    }
    func request(_ request: SKRequest, didFailWithError error:
    Error) {
        print("Error with the purchase \(error)")
    }
}

extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        purchaseStatusBlock?(.failed)
    }
    
    // MARK: - IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    if let transaction = transaction as? SKPaymentTransaction {
                        purchaseStatusBlock?(.purchased)
                        SKPaymentQueue.default().finishTransaction(transaction)
                        finishTransaction?()
                        
                    }
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    purchaseStatusBlock?(.failed)
                case .restored:
                    if let transaction = transaction as? SKPaymentTransaction {
                        SKPaymentQueue.default().finishTransaction(transaction)
                    }
                default: break
                }
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        if canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            return true
        } else {
            return false
        }
    }
}

extension SKProduct {
    var localizedCurrencyPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }

    var title: String? {
        switch productIdentifier {
        case IAPManager.shared.silverID:
            return "Silver"
        case IAPManager.shared.goldID:
            return "Gold"
        case IAPManager.shared.diamondID:
            return "Diamond"
        default:
            return nil
        }
    }
    
    var coinNumber: String? {
        switch productIdentifier {
        case IAPManager.shared.silverID:
            return "50 coins"
        case IAPManager.shared.goldID:
            return "100 coins"
        case IAPManager.shared.diamondID:
            return "150 coins"
        default:
            return nil
        }
    }
    
    var numberOfCoins: Int? {
        switch productIdentifier {
        case IAPManager.shared.silverID:
            return 50
        case IAPManager.shared.goldID:
            return 100
        case IAPManager.shared.diamondID:
            return 150
        default:
            return nil
        }
    }
}
