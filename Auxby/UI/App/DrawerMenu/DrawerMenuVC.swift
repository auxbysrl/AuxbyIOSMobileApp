//
//  DrawerMenuVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 23.11.2022.
//

import UIKit
import L10n_swift

class DrawerMenuVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private  var views: [UIView]!
    @IBOutlet private var titles: [UILabel]!
    @IBOutlet private var logos: [UIImageView]!
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var emailLabel: UILabel!
    
    @IBOutlet private weak var guestView: UIView!
    @IBOutlet private weak var userView: UIView!
    @IBOutlet private weak var coinsLabel: UILabel!
    @IBOutlet weak var alert: AlertView!
    
    // MARK: - Public properties
    let transitionManager = DrawerTransitionManager()
    let vm = DrawerMenuVM()
    
    // MARK: - Private properties
    var indicator: ActivityIndicator?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .custom
        transitioningDelegate = transitionManager
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let _ = Offline.currentUser {
            vm.getUsersOffers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func closeDrawer(_ sender: UIButton) {
        dismissVC()
    }
    
    @IBAction func goToLogin(_ sender: UIButton) {
        let loginVC = LoginVC.asVC()
        dismissVC(){
            topVC().pushVC(loginVC)
        }
    }
    
    @IBAction func selectView(_ sender: UIButton) {
        views.forEach {
            let color: UIColor = $0.tag == sender.tag ? .primaryLight : .background
            $0.backgroundColor = color
        }
        titles.forEach {
            let color: UIColor = $0.tag == sender.tag ? .white : .primaryLight
            $0.textColor = color
        }
        logos.forEach {
            let color: UIColor = $0.tag == sender.tag ? .white : .primaryLight
            $0.image = $0.image?.withRenderingMode(.alwaysTemplate)
            $0.tintColor = color
        }
        
        switch sender.tag {
        case 0:
            dismissVC() {
                topVC().pushVC(ProfileVC.asVC())
            }
        case 1:
            dismissVC() {
                topVC().pushVC(NotificationsVC.asVC())
            }
        case 3:
            dismissVC() {
                topVC().pushVC(MyOffersVC.asVC())
            }
        case 4:
            dismissVC() {
                topVC().pushVC(SettingsVC.asVC())
            }
            
        case 5:
            dismissVC() {
                topVC().pushVC(BuyCoinsVC.asVC())
            }
        case 6:
            dismissVC {
                if let newCat = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
                    guard let categoriesVC = CategoriesVC.asVC() as? CategoriesVC else { return }
                    categoriesVC.vm.shouldUseCategoryDetails = true
                    categoriesVC.vm.categoriesDetails = newCat
                    categoriesVC.vm.filtredCategoriesDetails = newCat
                    topVC().pushVC(categoriesVC)
                }
            }
        default: break
            
        }
    }
    
    @IBAction func bottomActions(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            if let url = URL(string: "https://www.auxby.ro/") {
                      if UIApplication.shared.canOpenURL(url) {
                          UIApplication.shared.open(url, options: [:], completionHandler: nil)
                      }
                  }
        case 1:
            if let url = URL(string: "https://www.auxby.ro/termeni-si-conditii") {
                      if UIApplication.shared.canOpenURL(url) {
                          UIApplication.shared.open(url, options: [:], completionHandler: nil)
                      }
                  }
        default:
            if let url = URL(string: "https://www.auxby.ro/politica-de-confidentialitate") {
                      if UIApplication.shared.canOpenURL(url) {
                          UIApplication.shared.open(url, options: [:], completionHandler: nil)
                      }
                  }
        }
    }
    
    @IBAction func showLogoutPopup(_ sender: UIButton) {
        var actions: [UIAlert.Option] = []
        actions.append(UIAlert.Option(title: "logout".l10n(),action: {
            self.vm.logout()
        }))
        actions.append(UIAlert.Option(title: "deleteAccount".l10n(),action: {
            self.alert.isHidden = false
        }, style: .destructive))
        UIAlert.showActionSheet(options: actions, iPadSourceView: profilePhoto)
    }
    
    
}
private extension DrawerMenuVC {
    func setView() {
        if let user = Offline.decode(key: .currentUser, type: User.self) {
            alert.setDelete(title: "areYouSureDelete".l10n(), content: "areYouSureDelete2".l10n(), secondButtonTitle: "confirm".l10n())
            alert.confirm = { [unowned self] in
                alert.isHidden = true
                vm.deleteUser()
            }
            alert.cancel = { [unowned self] in
                alert.isHidden = true
            }
            logos.first?.image = logos.first?.image?.withRenderingMode(.alwaysTemplate)
            logos.first?.tintColor = .primaryLight
            nameLabel.text = user.firstName + " " + user.lastName
            emailLabel.text = user.email
            if let url =  user.avatar {
                if let shouldReload = Offline.decode(key: .shouldReloadProfilePicture, type: Bool.self) {
                    if shouldReload {
                        profilePhoto.setImage(from: url, reload: shouldReload)
                        Offline.encode(false, key: .shouldReloadProfilePicture)
                    } else {
                        profilePhoto.setImage(from: url)
                    }
                }
            } else {
                profilePhoto.image = UIImage(named: Owner.noProfilePhoto)
            }
            coinsLabel.text = "\("avalableCoins".l10n()) \(user.availableCoins)"
            guestView.isHidden = true
            userView.isHidden = false
        } else {
            guestView.isHidden = false
            userView.isHidden = true
        }
    }
    
    func setObservable() {
        
        vm.$getLogoutState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                Offline.delete(key: .currentUser)
                Offline.delete(key: .favorites)
                Offline.delete(key: .offers)
                Offline.delete(key: .userOffers)
                Offline.delete(key: .currentAdd)
                Keychain.deleteAll()
                NotifyCenter.post(.noUser)
                self.setView()
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
        
        vm.$getDeleteUser.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                Offline.delete(key: .currentUser)
                Offline.delete(key: .favorites)
                Offline.delete(key: .offers)
                Offline.delete(key: .userOffers)
                Keychain.deleteAll()
                NotifyCenter.post(.noUser)
                self.setView()
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserOffers.sink { state in
            switch state {
            case .succeed(let offers):
                Offline.encode(offers, key: .userOffers)
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
}
