//
//  NotificationsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 04.09.2023.
//

import UIKit

class NotificationsVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var noNotificationsView: UIView!
    @IBOutlet weak var cv: UICollectionView!
    
    // MARK: - Public properties
    var vm = NotificationsVM()
    
    // MARK: - Private properties
    private var indicator: ActivityIndicator?
    
    // MARK: Overriden Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vm.getAllNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
}
// MARK: - Private Methods
private extension NotificationsVC {
    func setView() {
        setObservable()
    }
    
    func setObservable() {
        vm.$getNotificationsState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let response):
                vm.notifications = response
                Offline.encode(vm.notifications, key: .notifications)
                noNotificationsView.isHidden = !vm.notifications.isEmpty
                cv.reloadData()
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
        
        vm.$getDeleteState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                NotifyCenter.post(.updateNotifications)
                vm.getAllNotifications()
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

extension NotificationsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.notifications.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotificationCVCell.className, for: indexPath) as! NotificationCVCell
        cell.setCell(notification: vm.notifications[indexPath.row])
        cell.deleteAction = { [unowned self] in
            vm.deleteNotification(id: vm.notifications[indexPath.row].id ?? 0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        vm.deleteNotification(id: vm.notifications[indexPath.row].id ?? 0)
        AppNotificationType(rawValue: vm.notifications[indexPath.row].type)?.action(offerId: vm.notifications[indexPath.row].offerId)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 87)
    }
}
