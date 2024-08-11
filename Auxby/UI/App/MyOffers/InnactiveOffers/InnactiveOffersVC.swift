//
//  InnactiveOffersVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 27.03.2023.
//

import UIKit
import L10n_swift

class InnactiveOffersVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var cv: UICollectionView!
    @IBOutlet weak var noOffers: UIView!
    
    // MARK: - Public properties
    var vm: MyOffersVM!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.setButtons(isFirst: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setObservable()
        noOffers.isHidden = !vm.innactiveOffers.isEmpty
    }

}
private extension InnactiveOffersVC {
    func setObservable() {
        vm.$getUserOffers.sink { [unowned self] state in
            switch state {
            case .succeed(let offers):
                vm.activeOffers = []
                vm.innactiveOffers = []
                offers.forEach {
                    if $0.status == Offer.offerStatus.active.status {
                        vm.activeOffers.append($0)
                    } else {
                        vm.innactiveOffers.append($0)
                    }
                }
                noOffers.isHidden = !vm.activeOffers.isEmpty
                cv.reloadData()
                
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
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            vm.getAcctiveAndInnactive()
            noOffers.isHidden = !vm.innactiveOffers.isEmpty
            cv.reloadData()
        }.store(in: &vm.cancellables)
    }
}

extension InnactiveOffersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       vm.innactiveOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.className, for: indexPath) as! OfferCell
        cell.setCell(offer:  vm.innactiveOffers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer =  vm.innactiveOffers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            }
        }, viewOffers: nil, showUsers: nil)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            offerDetailsVC.vm = PreviewOrDetailsVM(offer:  vm.innactiveOffers[indexPath.row])
            pushVC(offerDetailsVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 32, height: 280)
    }
}
