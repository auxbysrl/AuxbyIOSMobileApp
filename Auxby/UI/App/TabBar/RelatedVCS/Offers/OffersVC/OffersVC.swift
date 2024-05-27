//
//  OffersVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.10.2022.
//

import UIKit
import NVActivityIndicatorView
import L10n_swift

class OffersVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var loggedButtons: UIStackView!
    @IBOutlet private weak var guestButtons: UIButton!
    @IBOutlet private weak var offersCV: UICollectionView!
    @IBOutlet private weak var loaderView: UIView!
    @IBOutlet private weak var dummyView: UIView!
    @IBOutlet private weak var loader: NVActivityIndicatorView!
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var notificationsBell: UIButton!
    
    // MARK: - Public properties
    var vm  = OffersVM()
    var timer: Timer?
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    private var refreshControl: UIRefreshControl!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setView()
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            vm.getAllNotifications()
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.getCategories()
        vm.currentPage = 0
        vm.offers = []
        offersCV.reloadData()
        setView()
        vm.getPromotedOffers()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func showMenu(_ sender: UIButton) {
        presentVC(DrawerMenuVC.asVC())
    }
    
    @IBAction func goToLogin(_ sender: Any) {
        pushVC(LoginVC.asVC())
    }
    
    @IBAction func goToSearch(_ sender: UIButton) {
        Offline.delete(key: .currentSearch)
        pushVC(SearchVC.asVC())
    }
    
    @IBAction func goToNotifications(_ sender: UIButton) {
        pushVC(NotificationsVC.asVC())
    }
}

private extension OffersVC {
    func setBell() {
        if let notifications = Offline.decode(key: .notifications, type: [AppNotification].self) {
            let image = UIImage(named: notifications.count > 0 ? "bellNotifications" : "bell")
            notificationsBell.setImage(image, for: .normal)
        }
    }
    
    func setView() {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            loggedButtons.isHidden = false
            guestButtons.isHidden = true
            logo.image = UIImage(named: "logoAndText")
        } else {
            loggedButtons.isHidden = true
            guestButtons.isHidden = false
            logo.image = UIImage(named: "logoAndTextGuest")
        }
        offersCV.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        loader.type = .ballSpinFadeLoader
        loader.color = .primaryLight
        loader.startAnimating()
        setRefresh()
    }
    
    func setRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(getOffers), for: .valueChanged)
        offersCV.refreshControl = refreshControl
        offersCV.refreshControl?.bounds = refreshControl.bounds.offsetBy(dx: 0, dy: -80)
    }
    
    @objc func getOffers() {
        vm.currentPage = 0
        vm.isRefreshing = true
        vm.getPromotedOffers()
        vm.getCategories()
    }
    
    func setObservable() {
        NotifyCenter.observable(for: .updateNotifications).sink { [unowned self]  in
            if let _ = Offline.decode(key: .currentUser, type: User.self) {
                vm.getAllNotifications()
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .newMessage).sink { [unowned self]  in
            if let _ = Offline.decode(key: .currentUser, type: User.self) {
                vm.getAllNotifications()
            }
        }.store(in: &vm.cancellables)
        
        vm.$getNotificationsState.sink {[unowned self] state in
            switch state {
            case .succeed(let notifications):
                Offline.encode(notifications, key: .notifications)
                setBell()
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getCategoriesState.sink { [unowned self] state in
            switch state {
            case .succeed(let categories):
                vm.categories = categories
                Offline.encode(categories, key: .categories)
               
                offersCV.reloadData()
            case .failed(let err):
                //UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getPromotedOffersState.sink { [unowned self] state in
            if vm.currentPage == 0 && vm.isRefreshing == false {
                state.setStateActivityIndicator(&indicator)
            }
            switch state {
            case .succeed(let offers):
                vm.currentPromotedOffers = offers
                vm.getOffers()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                vm.isLoading = false
                refreshControl?.endRefreshing()
                loaderView.isHidden = true
                dummyView.isHidden = true
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getOffersState.sink { [unowned self] state in
            if vm.currentPage == 0 && vm.isRefreshing == false {
                state.setStateActivityIndicator(&indicator)
            }
            switch state {
            case .succeed(let offersResponse):
                loaderView.isHidden = true
                dummyView.isHidden = true
                refreshControl?.endRefreshing()
                vm.isLoading = false
                if vm.currentPage == 0 {
                    for offer in vm.currentPromotedOffers {
                        if !vm.offers.contains(where: {$0.id == offer.id}) {
                            vm.offers.append(offer)
                        }
                    }
                    
                    for offer in offersResponse.content {
                        if !vm.offers.contains(where: {$0.id == offer.id}) {
                            vm.offers.append(offer)
                        }
                    }
                    UpdateService.shared.startTimer()
                } else {
                    var promotedAddedOffers = 0
                    for promotedOffer in vm.currentPromotedOffers {
                        if !vm.offers.contains(where: {$0.id == promotedOffer.id}) {
                            vm.offers.append(promotedOffer)
                            promotedAddedOffers += 1
                        }
                        else {
                           if let index = vm.offers.firstIndex(where: { $0.id == promotedOffer.id}) {
                               vm.offers[index] = promotedOffer
                           }
                       }
                    }
                    let previousSize = offersResponse.page * offersResponse.size + promotedAddedOffers
                    if vm.offers.count < (previousSize + offersResponse.content.count) {
                        for offer in offersResponse.content {
                            if !vm.offers.contains(where: {$0.id == offer.id}) {
                                vm.offers.append(offer)
                            } else {
                                if let index = vm.offers.firstIndex(where: { $0.id == offer.id}) {
                                    vm.offers[index] = offer
                                }
                            }
                        }
                    }
                }
                vm.totalPages = offersResponse.totalPages
                Offline.encode(vm.offers, key: .offers)
                offersCV.reloadData()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                vm.isLoading = false
                refreshControl?.endRefreshing()
                loaderView.isHidden = true
                dummyView.isHidden = true
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getOffersByCategoryState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let response):
                let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
                offerDetailsVC.vm = PreviewOrDetailsVM(offer: response.content[0])
                topVC().pushVC(offerDetailsVC)
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
            
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            if let offers = Offline.decode(key: .offers, type: [Offer].self) {
                vm.offers = offers
                offersCV.reloadData()
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .noUser).sink { [unowned self] _ in
            dummyView.isHidden = false
            vm.isRefreshing = false
            vm.getCategories()
            vm.currentPage = 0
            vm.getPromotedOffers()
            setView()
        }.store(in: &vm.cancellables)
    }
    
    func setTimer(cell: OfferHeaderCell) {
        if vm.offers.count > 0 {
            if timer == nil {
                DispatchQueue.main.async {
                    self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: {  _ in
                        cell.setTimer()
                    })
                }
            }
        }
    }
    
}

extension OffersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       vm.offers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.className, for: indexPath) as! OfferCell
        cell.setCell(offer: vm.offers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer = vm.offers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            } else {
                presentVC(GuestModeVC.asVC())
            }
        }, viewOffers: nil, showUsers: nil)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            offerDetailsVC.vm = PreviewOrDetailsVM(offer: vm.offers[indexPath.row])
            pushVC(offerDetailsVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 280)
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
                    vm.getPromotedOffers()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: OfferHeaderCell.className, for: indexPath) as! OfferHeaderCell
        headerCell.setCell(categories: vm.categories, offers: vm.currentPromotedOffers) {
            let categoriesVC = CategoriesVC.asVC()
            self.pushVC(categoriesVC)
        }
        headerCell.presentOneOffer = { [unowned self] categoryId in
            vm.getOffersByCategory(categoryId: categoryId)
        }
        setTimer(cell: headerCell)
        return headerCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 16, height: 450)
    }
}
