//
//  ActiveOffersVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 27.03.2023.
//

import UIKit
import L10n_swift

class ActiveOffersVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var noOffers: UIView!
    
    // MARK: - Public properties
    var vm: MyOffersVM!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.setButtons(isFirst: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservable()
        noOffers.isHidden = !vm.activeOffers.isEmpty
    }
    
}
private extension ActiveOffersVC {
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
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            vm.getAcctiveAndInnactive()
            noOffers.isHidden = !vm.activeOffers.isEmpty
            cv.reloadData()
        }.store(in: &vm.cancellables)
    }
}

extension ActiveOffersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.activeOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.className, for: indexPath) as! OfferCell
        cell.setCell(offer:  vm.activeOffers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer =  vm.activeOffers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            }
        }, viewOffers: nil, showUsers: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
        offerDetailsVC.vm = PreviewOrDetailsVM(offer:  vm.activeOffers[indexPath.row])
        pushVC(offerDetailsVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 32, height: 280)
    }
}
