//
//  PlaceBidVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.03.2023.
//

import UIKit
import L10n_swift

class PlaceBidVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var placeBidView: UIView!
    @IBOutlet private weak var bidTextField: UITextField!
    @IBOutlet private weak var convertedValueLabel: UILabel!
    @IBOutlet private weak var highestBidLabel: UILabel!
    @IBOutlet private weak var bidCostLabel: UILabel!
    @IBOutlet private weak var coinsBalanceLabel: UILabel!
    @IBOutlet private weak var placeBidHeight: NSLayoutConstraint!
    @IBOutlet private weak var currencyLabel: UILabel!
    @IBOutlet private weak var placeBidButton: UIButton!
    @IBOutlet weak var alert: AlertView!
    
    // MARK: - Public properties
    var vm: PlaceBidVM!
    var lastValue = 0
    var isEnable = true
    var bidPlaced: (() -> Void)?
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.user = Offline.decode(key: .currentUser, type: User.self)!
        setView()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    
    @IBAction func back(_ sender: UIButton) {
        dismissVC()
    }
    
    @IBAction func placeBid(_ sender: UIButton) {
        if vm.user.availableCoins < vm.bidPrice {
            let title = "notEnoughCoins".l10n()
            let content = "coinsBalance".l10n() + " \(vm.user.availableCoins)"
            alert.set(title: title, content: content, secondButtonTitle: "buyMore".l10n())
            alert.cancel = { [unowned self] in
                alert.isHidden = true
            }
            alert.confirm = { [unowned self] in
                alert.isHidden = true
                presentVC(BuyCoinsVC.asVC())
            }
            alert.isHidden = false
        } else {
            vm.placeBid(amount: lastValue)
        }
    }
    
    @IBAction func substractFromBid(_ sender: UIButton) {
        if lastValue > vm.yourBid {
            lastValue -= vm.minimExtraBid
        }
        bidTextField.text = formattedString(number: lastValue)
    }
    
    @IBAction func addToBid(_ sender: UIButton) {
        if lastValue < vm.maxValue {
            lastValue += vm.minimExtraBid
        }
        bidTextField.text = formattedString(number: lastValue)
    }
}
private extension PlaceBidVC {
    func setView() {
        hideKeyboardWhenTappedAround()
        delay(0.1) {
            self.placeBidView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        }
        bidCostLabel.text = "bidCost".l10n() + " \(vm.bidPrice)"
        coinsBalanceLabel.text = "coinsBalance".l10n() + " \(vm.user.availableCoins)"
        bidTextField.text = formattedString(number: vm.yourBid)
        currencyLabel.text = vm.offer.currencyType?.getCurrency
        highestBidLabel.text = "highestBid".l10n() + " \(formattedString(number: vm.highestBid))\(vm.offer.currencyType!.getCurrency)"
        lastValue = vm.yourBid
    }
    
    func setObservable() {
        vm.$getBidState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let response):
                if response.wasBidAccepted {
                    dismissVC()
                    bidPlaced?()
                } else {
                    UIAlert.showOneButton(message: "bidDeclined".l10n()) {
                        self.vm.getOffer()
                    }
                }
            case .failed:
                UIAlert.showOneButton(message: "errorBid".l10n())
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getOfferState.sink { [unowned self] state in
            switch state {
            case .succeed(let offer):
                vm.resetOffer(offer: offer)
                setView()
            case .failed:
                UIAlert.showOneButton(message: "somethingWentWrong".l10n()){
                    self.dismissVC()
                }
            default: break
            }
        }.store(in: &vm.cancellables)
    }
    
    func formattedString(number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

extension PlaceBidVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        placeBidHeight.constant = 690
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
       
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = "."
            let newText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? ""
            let strippedText = newText.replacingOccurrences(of: formatter.groupingSeparator, with: "")
            if let number = formatter.number(from: strippedText) {
                if Int(truncating: number) < vm.maxValue {
                    lastValue = Int(truncating: number)
                    textField.text = formatter.string(from: number)
                    if lastValue < vm.highestBid {
                        convertedValueLabel.text = "Can't be lower then \(vm.highestBid)"
                        convertedValueLabel.textColor = .red
                        isEnable = false
                        let color: UIColor = .primaryDark.withAlphaComponent(0.8)
                        placeBidButton.backgroundColor = color
                    } else {
                        convertedValueLabel.text = "Converted value: 1000 lei"
                        convertedValueLabel.textColor = .textDark
                        isEnable = true
                        placeBidButton.backgroundColor = .primaryLight
                    }
                }
            } else {
                textField.text = strippedText
            }
            return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        placeBidHeight.constant = 400
    }
}
