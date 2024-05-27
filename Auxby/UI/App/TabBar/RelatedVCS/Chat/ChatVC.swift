//
//  ChatVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 26.10.2022.
//

import UIKit
import L10n_swift

class ChatVC: PageControllerDataSource {
    
    // MARK: - IBOutlets
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var userSV: UIStackView!
    @IBOutlet weak var guestModeView: UIView!
    @IBOutlet weak var segmentControl: SegmentControlView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var notificationsBell: UIButton!
    // MARK: - Public properties
    var vm = ChatVM()
    
    // MARK: - Private properties
    private var lastSelectedSegmentIndex = 0
    private var buyChats: BuyChatVC!
    private var sellChats: SellChatVC!
    private var indicator: ActivityIndicator?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setView()
        setBell()
        if let _ = Offline.currentUser {
            vm.getChats()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservable()
    }
    
    // MARK: - IBActions
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

private extension ChatVC {
    func setView() {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            logInButton.isHidden = true
            userSV.isHidden = false
            guestModeView.isHidden = true
        } else {
            logInButton.isHidden = false
            userSV.isHidden = true
            guestModeView.isHidden = false
        }
    }
    
    func setBell() {
        if let notifications = Offline.decode(key: .notifications, type: [AppNotification].self) {
            let image = UIImage(named: notifications.count > 0 ? "bellNotifications" : "bell")
            notificationsBell.setImage(image, for: .normal)
        }
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
            vm.getChats()
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
        
        vm.$getChatsState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let chats):
                vm.chats = chats
                buyChats = nil
                sellChats = nil
                setChats()
                setPageControllers()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                buyChats = nil
                sellChats = nil
                setPageControllers()
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
    }
    
    func setChats() {
        if let readedChats = Offline.decode(key: .readedChats, type: [CompleteChat].self) {
            vm.buyChats = []
            vm.sellChats = []
            for chat in vm.chats {
                var date: Date? = nil
                if let readedChat = readedChats.first(where: { $0.chat.roomId == chat.roomId }) {
                    date = readedChat.readDate
                }
                if chat.isRoomHost {
                    vm.buyChats.append(CompleteChat(chat: chat, readDate: date))
                } else {
                    vm.sellChats.append(CompleteChat(chat: chat, readDate: date))
                }
            }
        } else {
            vm.buyChats = []
            vm.sellChats = []
            for chat in vm.chats {
                if chat.isRoomHost {
                    let date: Date? = nil
                    vm.buyChats.append(CompleteChat(chat: chat, readDate: date))
                } else {
                    let date: Date? = nil
                    vm.sellChats.append(CompleteChat(chat: chat, readDate: date))
                }
            }
        }
        
        vm.buyChats.sort {$0.chat.lastMessageTime > $1.chat.lastMessageTime}
        vm.sellChats.sort {$0.chat.lastMessageTime > $1.chat.lastMessageTime}
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
        setPageController(vcs: [buyChats, sellChats], containerView: containerView)
        goTo(index: lastSelectedSegmentIndex, animated: false)
    }
    
    func setPageVCs() {
        if buyChats == nil {
            buyChats = BuyChatVC.asVC() as? BuyChatVC
            buyChats.vm = vm
        }
        if sellChats == nil {
            sellChats = SellChatVC.asVC() as? SellChatVC
            sellChats.vm = vm
        }
    }
}
