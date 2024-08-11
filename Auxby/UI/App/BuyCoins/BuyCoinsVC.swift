//
//  BuyCoinsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.12.2022.
//

import UIKit
import L10n_swift
import StoreKit

class BuyCoinsVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var mainButton: MainButtonView!
    @IBOutlet private var bundleNames: [UILabel]!
    @IBOutlet private var bundleValues: [UILabel]!
    @IBOutlet private var checkedImage: [UIImageView]!
    @IBOutlet private var bundlePrices: [UILabel]!
    @IBOutlet var bundles: [UIView]!
    
    // MARK: - Public properties
    var vm = BuyCoinsVM()
    
    // MARK: - Private properties
    var indicator: ActivityIndicator?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       indicator = ActivityIndicator()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
  
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        if isModal {
            dismissVC()
        } else {
            popVC()
        }
    }
    
    @IBAction func selectBundle(_ sender: UIButton) {
        checkedImage.forEach {
            $0.isHidden = $0.tag != sender.tag
        }
        vm.selectedBundle = sender.tag
    }
}

private extension BuyCoinsVC {
    func setView() {
        IAPManager.shared.initialize()
               IAPManager.shared.fetchAvailableProductsBlock = { (productsArray) in
                   DispatchQueue.main.async { [unowned self] in
                       indicator?.hide()
                       indicator = nil
                       if productsArray.isEmpty {
                           UIAlert.showOneButton(message: "somethingWentWrong".l10n()) { [unowned self] in
                               if isModal {
                                   dismissVC()
                               } else {
                                   popVC()
                               }
                           }
                       } else {
                           vm.products = productsArray
                           vm.products.sort{($0.price as Decimal) < ($1.price as Decimal) }
                           setProducts(productsArray: vm.products)
                       }
                       
                   }
               }
        mainButton.set(title: "buyCoins".l10n()) { [unowned self] in
            if let bundle = vm.selectedBundle {
                let selectedProduct = vm.products[bundle]
                IAPManager.shared.purchaseMyProduct(productIdentifier: selectedProduct.productIdentifier)
                IAPManager.shared.finishTransaction = { [unowned self] in
                    vm.finishTransaction(product: selectedProduct)
                }
            }
    
        }
        checkedImage.forEach {
            $0.isHidden = $0.tag != vm.selectedBundle
        }
        setObservable()
    }
    
    func setObservable() {
        vm.$getTransactionStatus.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                vm.getUser()
               
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case.succeed(let user):
                Offline.encode(user, key: .currentUser)
                NotifyCenter.post(.updateUser)
                if isModal {
                    dismissVC()
                } else {
                    popVC()
                }
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
    
    func setProducts(productsArray: [SKProduct]) {
        for i in 0...productsArray.count - 1 {
            bundles.first{ $0.tag == i }?.isHidden = false
            bundleNames.first{ $0.tag == i }?.text = productsArray[i].title
            bundleValues.first{ $0.tag == i }?.text = productsArray[i].coinNumber
            bundlePrices.first{ $0.tag == i }?.text =  productsArray[i].localizedCurrencyPrice
        }
    }
}
