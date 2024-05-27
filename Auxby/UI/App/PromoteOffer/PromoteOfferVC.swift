//
//  PromoteOfferVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.05.2023.
//

import UIKit
import L10n_swift

class PromoteOfferVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var buttonLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var alert: AlertView!
    
    // MARK: - Public properties
    var vm: PromoteOfferVM!
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        if vm.isFromPreview {
            popVC(4)
        } else {
            popVC()
        }
    }
    
    @IBAction func promote(_ sender: UIButton) {
        if vm.user.availableCoins < vm.selectedPromoted.price {
            let title = "notEnoughCoins".l10n()
            let content = "coinsBalance".l10n() + " \(vm.user.availableCoins)"
            alert.set(title: title, content: content, secondButtonTitle: "buyMore".l10n())
            alert.cancel = { [unowned self] in
                alert.isHidden = true
            }
            alert.confirm = { [unowned self] in
                alert.isHidden = true
                pushVC(BuyCoinsVC.asVC())
            }
            alert.isHidden = false
        } else {
            vm.promoteOffer()
        }
    }
}
private extension PromoteOfferVC {
    func setView() {
        buttonLabel.text = "promoteFor".l10n() + " \(vm.selectedPromoted.price)"
        backButton.isHidden = vm.isFromPreview
        let title = vm.isFromPreview ? "continueWithout".l10n() : "cancel".l10n()
        cancelButton.setTitle(title, for: .normal)
    }
    
    func setObservable() {
        vm.$getPromoteOfferState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                vm.getUser()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case.succeed(let user):
                Offline.encode(user, key: .currentUser)
                UIAlert.showOneButton(message: "succesfullyPromote".l10n()) {
                    self.popVC()
                }
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}

extension PromoteOfferVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.promoteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PromoteCVCell.className, for: indexPath) as! PromoteCVCell
        let isSelected = vm.promoteList[indexPath.row].days == vm.selectedPromoted.days
        cell.setCell(promote: vm.promoteList[indexPath.row], isSelected: isSelected)
        return cell
    }
      
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        vm.selectedPromoted = vm.promoteList[indexPath.row]
        cv.reloadData()
        setView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 92)
    }
}
