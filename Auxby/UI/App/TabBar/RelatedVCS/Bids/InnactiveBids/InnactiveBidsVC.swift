//
//  InnactiveBidsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.04.2023.
//

import UIKit
import L10n_swift

class InnactiveBidsVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var noOffers: UIView!
    
    // MARK: - Public properties
    var vm: BidsVM!
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.setButtons(isFirst: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        noOffers.isHidden = !vm.innactiveOffers.isEmpty
        setObservable()
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    }
}
private extension InnactiveBidsVC {
    func setObservable() {
        vm.$getUserBidsState.sink { [unowned self] state in
            if vm.isFirstTime {
                state.setStateActivityIndicator(&indicator)
            }
            switch state {
            case .succeed(let offers):
                vm.isFirstTime = false
                Offline.encode(offers, key: .userBids)
                vm.getActiveAndInnactive()
                cv.reloadData()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            vm.getActiveAndInnactive()
            noOffers.isHidden = !vm.innactiveOffers.isEmpty
            cv.reloadData()
        }.store(in: &vm.cancellables)
    }
}

extension InnactiveBidsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
