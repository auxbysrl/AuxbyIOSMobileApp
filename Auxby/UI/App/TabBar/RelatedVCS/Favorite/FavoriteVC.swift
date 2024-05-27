//
//  FavouriteVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.10.2022.
//

import UIKit
import L10n_swift

class FavoriteVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var favortiesCV: UICollectionView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var userSV: UIStackView!
    @IBOutlet weak var guestModeView: UIView!
    @IBOutlet weak var noOffer: UIView!
    @IBOutlet weak var dummyView: UIView!
    @IBOutlet weak var notificationsBell: UIButton!
    
    // MARK: - Public properties
    var vm = FavoriteVM()
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let offers = Offline.decode(key: .favorites, type: [Offer].self) {
            dummyView.isHidden = true
            noOffer.isHidden = true
            vm.favoriteOffers = offers
            vm.favoriteOffers = vm.favoriteOffers.sorted { first, second in
                first.id > second.id
            }
            favortiesCV.reloadData()
            if let _ = Offline.currentUser {
                noOffer.isHidden = !vm.favoriteOffers.isEmpty
            } else {
                dummyView.isHidden = true
                noOffer.isHidden = true
            }
        }
        if let _ = Offline.currentUser {
            vm.getFavorites()
        }
        setView()
        setBell()
        setObservable()
    }
    
    @IBAction func showDrawer(_ sender: UIButton) {
        let drawerVC = DrawerMenuVC.asVC()
        presentVC(drawerVC)
    }
    
    
    @IBAction func goToLogin(_ sender: UIButton) {
        let loginVc = LoginVC.asVC()
        pushVC(loginVc)
    }
    
    @IBAction func goToRegister(_ sender: UIButton) {
        let loginVc = LoginVC.asVC()
        pushVC(loginVc)
    }
    
    @IBAction func goToSearch(_ sender: UIButton) {
        Offline.delete(key: .currentSearch)
        pushVC(SearchVC.asVC())
    }
    
    @IBAction func goToNotifications(_ sender: UIButton) {
        pushVC(NotificationsVC.asVC())
    }
}

private extension FavoriteVC {
    func setBell() {
        if let notifications = Offline.decode(key: .notifications, type: [AppNotification].self) {
            let image = UIImage(named: notifications.count > 0 ? "bellNotifications" : "bell")
            notificationsBell.setImage(image, for: .normal)
        }
    }
    func setView() {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            logInButton.isHidden = true
            userSV.isHidden = false
            guestModeView.isHidden = true
        } else {
            logInButton.isHidden = false
            userSV.isHidden = true
            guestModeView.isHidden = false
            noOffer.isHidden = true
            dummyView.isHidden = true
        }
        favortiesCV.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 100, right: 0)
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
            case .failed:
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
            default: break
            }
        }.store(in: &vm.cancellables)
        vm.$getFavoritesState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let offers):
                dummyView.isHidden = true
                vm.favoriteOffers = offers
                vm.favoriteOffers = vm.favoriteOffers.sorted { first, second in
                    first.id > second.id
                }
                favortiesCV.reloadData()
                if let _ = Offline.currentUser {
                    noOffer.isHidden = !vm.favoriteOffers.isEmpty
                } else {
                    noOffer.isHidden = true
                }
                Offline.encode(offers, key: .favorites)
            case .failed(let err):
                dummyView.isHidden = true
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getAddToFavoriteState.sink { [unowned self] state in
            switch state {
            case .succeed:
                if let offers = Offline.decode(key: .favorites, type: [Offer].self) {
                    vm.favoriteOffers = offers
                    vm.favoriteOffers = vm.favoriteOffers.sorted { first, second in
                        first.id > second.id
                    }
                    favortiesCV.reloadData()
                    if let _ = Offline.currentUser {
                        noOffer.isHidden = !vm.favoriteOffers.isEmpty
                    } else {
                        noOffer.isHidden = true
                    }
                }
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .updateOffers).sink { [unowned self] _ in
            if let offers = Offline.decode(key: .favorites, type: [Offer].self) {
                vm.favoriteOffers = offers
                vm.favoriteOffers = vm.favoriteOffers.sorted { first, second in
                    first.id > second.id
                }
                favortiesCV.reloadData()
                if let _ = Offline.currentUser {
                    noOffer.isHidden = !vm.favoriteOffers.isEmpty
                } else {
                    noOffer.isHidden = true
                }
            }
        }.store(in: &vm.cancellables)
    }
}

extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       vm.favoriteOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.className, for: indexPath) as! OfferCell
        cell.setCell(offer:  vm.favoriteOffers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer =  vm.favoriteOffers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            }
        }, viewOffers: nil, showUsers: nil)
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            offerDetailsVC.vm = PreviewOrDetailsVM(offer:  vm.favoriteOffers[indexPath.row])
            pushVC(offerDetailsVC)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 32, height: 280)
    }
}
