//
//  OfferByCategoryVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 13.02.2023.
//

import UIKit
import L10n_swift
import NVActivityIndicatorView


class OffersByCategoryVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var numberOfOffersLabel: UILabel!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var cv: UICollectionView!
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var Loader: NVActivityIndicatorView!
    
    // MARK: - Public properties
    var vm: OffersByCategoryVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func openFilters(_ sender: UIButton) {
    }
    
    @IBAction func openSortDetails(_ sender: UIButton) {
    }
}

private extension OffersByCategoryVC {
    func setView() {
        titleLabel.text = vm.selectedCategory.label.first(where: { $0.language == L10n.shared.language
        })?.translation
        categoryLabel.text = vm.selectedCategory.label.first(where: { $0.language == L10n.shared.language
        })?.translation
        numberOfOffersLabel.text = vm.selectedCategory.noOffers == 0 ? "noOffers".l10n() : vm.selectedCategory.noOffers == 1 ? "1 " + "offerIn".l10n() : "\(vm.selectedCategory.noOffers) " + "offersIn".l10n()
    }
    
    func setObservable() {
        vm.$getOffersState.sink { [unowned self] state in
            switch state {
            case .succeed(let offersResponse):
                loaderView.isHidden = true
                vm.isLoading = false
                if vm.currentPage == 0 {
                    vm.filteredOffers = offersResponse.content
                } else {
                    let previousSize = offersResponse.page * offersResponse.size
                    if vm.filteredOffers.count < (previousSize + offersResponse.content.count) {
                        vm.filteredOffers += offersResponse.content
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
                vm.filteredOffers = offers.filter { $0.categoryId == vm.selectedCategory.id }
                cv.reloadData()
            }
        }.store(in: &vm.cancellables)
    }
}

extension OffersByCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.filteredOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SmallOfferCell.className, for: indexPath) as!SmallOfferCell
        cell.setCell(offer: vm.filteredOffers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer = vm.filteredOffers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            } else {
                presentVC(GuestModeVC.asVC())
            }
        }, viewOffers: nil, showUsers: nil, isLeft: indexPath.row % 2 == 0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            offerDetailsVC.vm = PreviewOrDetailsVM(offer: vm.filteredOffers[indexPath.row])
            pushVC(offerDetailsVC)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        if offsetY > (contentHeight - height + 100 ) {
            loaderView.isHidden = !vm.isLoading
        }
        if offsetY > (contentHeight - height - 200) {
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
        return CGSize(width: collectionView.frame.width / 2 - 4, height: 180)
    }
}
