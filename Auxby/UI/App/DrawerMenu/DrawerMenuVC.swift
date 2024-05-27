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
    
    // MARK: - Public properties
    let transitionManager = DrawerTransitionManager()
    let vm = DrawerMenuVM()
    
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
    
}
private extension DrawerMenuVC {
    func setView() {
        if let user = Offline.decode(key: .currentUser, type: User.self) {
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
        vm.$getUserOffers.sink { state in
            switch state {
            case .succeed(let offers):
                Offline.encode(offers, key: .userOffers)
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}
