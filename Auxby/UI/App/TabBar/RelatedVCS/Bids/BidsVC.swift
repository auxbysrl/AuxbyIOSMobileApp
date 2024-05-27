//
//  BidsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.10.2022.
//

import UIKit
import L10n_swift

class BidsVC: PageControllerDataSource {
    // MARK: - IBOutlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var segmentControl: SegmentControlView!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var userSV: UIStackView!
    @IBOutlet weak var guestModeView: UIView!
    @IBOutlet weak var dummyView: UIView!
    @IBOutlet weak var notificationsBell: UIButton!
    
    // MARK: - Private properties
    private var lastSelectedSegmentIndex = 0
    private var activeBids: ActiveBidsVC!
    private var innactiveBids: InnactiveBidsVC!
    private var indicator: ActivityIndicator?
    
    // MARK: - Public properties
    var vm = BidsVM()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let  _ = Offline.currentUser {
            vm.getUserBids()
        }
        setBell()
        setView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservables()
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
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

private extension BidsVC {
    func setView() {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            logInButton.isHidden = true
            userSV.isHidden = false
            guestModeView.isHidden = true
        } else {
            logInButton.isHidden = false
            userSV.isHidden = true
            guestModeView.isHidden = false
            dummyView.isHidden = true
        }
    }
    
    func setBell() {
        if let notifications = Offline.decode(key: .notifications, type: [AppNotification].self) {
            let image = UIImage(named: notifications.count > 0 ? "bellNotifications" : "bell")
            notificationsBell.setImage(image, for: .normal)
        }
    }
    
    func setObservables() {
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
        
        vm.$getUserBidsState.sink { [unowned self] state in
            if vm.isFirstTime {
                state.setStateActivityIndicator(&indicator)
            }
            switch state {
            case .succeed(let offers):
                vm.isFirstTime = false
                dummyView.isHidden = true
                Offline.encode(offers, key: .userBids)
                vm.getActiveAndInnactive()
                setPageControllers()
            case .failed(let err):
                dummyView.isHidden = true
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .noUser).sink { [unowned self] _ in
            setView()
        }.store(in: &vm.cancellables)
    }
    
    func setPageControllers(){
        setPageVCs()
        segmentControl.action = { [unowned self] firstIndex in
            let index = firstIndex ? 0 : 1
            lastSelectedSegmentIndex = index
            goTo(index: index)
        }
        vm.selectAction = { [unowned self] firstIndex in
            segmentControl.setButtons(isFirst: firstIndex)
        }
        setPageController(vcs: [activeBids, innactiveBids], containerView: containerView)
        goTo(index: lastSelectedSegmentIndex, animated: false)
    }
    
    func setPageVCs() {
        if activeBids == nil {
            activeBids = ActiveBidsVC.asVC() as? ActiveBidsVC
            activeBids.vm = vm
        } else {
            activeBids.vm = vm
        }
        if innactiveBids == nil {
            innactiveBids = InnactiveBidsVC.asVC() as? InnactiveBidsVC
            innactiveBids.vm = vm
        } else {
            innactiveBids.vm = vm
        }
    }
}
