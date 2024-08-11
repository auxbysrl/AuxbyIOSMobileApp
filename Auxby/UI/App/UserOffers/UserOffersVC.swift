//
//  UserOffersVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.06.2024.
//

import UIKit
import NVActivityIndicatorView

class UserOffersVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var activeLabel: UILabel!
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var Loader: NVActivityIndicatorView!
    
    // MARK: - Public properties
    var vm: UserOffersVM!
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
}
// MARK: - Private Methods
private extension UserOffersVC {
    func setView() {
        vm.getOffers()
        if let avatar = vm.owner.avatarUrl {
            profileImage.setImage(from: avatar)
        } else {
            profileImage.image = UIImage(named: Owner.noProfilePhoto)
        }
        fullNameLabel.text = "\(vm.owner.lastName ?? "") \(vm.owner.firstName ?? "")"
        activeLabel.text = vm.owner.getActiveString()
    }
    
    func setObservable() {
        vm.$getUserOffers.sink { [unowned self] state in
            switch state {
            case .succeed(let offersResponse):
                loaderView.isHidden = true
                vm.isLoading = false
                if vm.currentPage == 0 {
                    vm.offers = offersResponse.content
                } else {
                    let previousSize = offersResponse.page * offersResponse.size
                    if vm.offers.count < (previousSize + offersResponse.content.count) {
                        vm.offers += offersResponse.content
                    }
                }
                vm.totalPages = offersResponse.totalPages
                cv.reloadData()
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n()) {
                        self.popVC()
                    }
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n()) {
                        self.popVC()
                    }
                }
                vm.isLoading = false
                loaderView.isHidden = true
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            if let offers = Offline.decode(key: .offers, type: [Offer].self) {
                for offer in vm.offers {
                    if let newOffer = offers.first(where: { $0.id == offer.id}), let index = vm.offers.firstIndex(where: {  $0.id == offer.id }) {
                        vm.offers[index] = newOffer
                    }
                }  
                cv.reloadData()
            }
        }.store(in: &vm.cancellables)
    }
}

extension UserOffersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.className, for: indexPath) as! OfferCell
        cell.setCell(offer:  vm.offers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer =  vm.offers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            }
        }, viewOffers: nil, showUsers: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
        offerDetailsVC.vm = PreviewOrDetailsVM(offer:  vm.offers[indexPath.row])
        popVC(2)
        pushVC(offerDetailsVC)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > (contentHeight - height + 100 ) {
            loaderView.isHidden = !vm.isLoading
        }
        if offsetY > (contentHeight - height - 400) {
            if !vm.isLoading {
                if vm.currentPage < vm.totalPages - 1 {
                    vm.isLoading = true
                    vm.currentPage += 1
                    vm.getOffers()
                }
            }

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 280)
    }
}
