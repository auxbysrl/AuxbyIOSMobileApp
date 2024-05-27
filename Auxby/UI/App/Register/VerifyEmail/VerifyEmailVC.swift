//
//  VerifyEmailVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 31.10.2022.
//

import UIKit
import L10n_swift

class VerifyEmailVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var emailLabel: UILabel!
    
    // MARK: - Public properties
    var vm: VerifyEmailVM!
    var timerForLogin: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func openMail(_ sender: UIButton) {
        let mailURL = URL(string: "message://")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL)
        }
    }
    
    @IBAction func resendEmail(_ sender: UIButton) {
        vm.resendEmail()
    }
    
    
    @IBAction func goToHome(_ sender: UIButton) {
        timerForLogin?.invalidate()
        timerForLogin = nil
        if vm.neetToPop != 0 {
            popVC(vm.neetToPop + 1)
        } else {
            let tabBarVC = TabBarVC.asVC()
            pushVC(tabBarVC)
        }
    }
}

private extension VerifyEmailVC {
    func setView() {
        emailLabel.text = vm.email
        if timerForLogin == nil {
            timerForLogin = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { [unowned self] _ in
                vm.login(email: vm.email, password: vm.password)
            })
        }
    }
    
    func setObservable() {
        vm.$loginState.sink { [unowned self] state in
            switch state {
            case .succeed(let loginResponse):
                if let token = loginResponse.token {
                    Keychain.save(value: token, item: .token)
                }
                timerForLogin?.invalidate()
                timerForLogin = nil
                vm.getUser()
                vm.saveApns()
               
            default : break
            }
        }.store(in: &vm.cancellables)
        
        vm.$resendEmailState.sink { state in
            switch state {
            case .succeed:
                UIAlert.showOneButton(message: "emailSent".l10n())
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserState.sink { [unowned self] state in
            switch state {
            case.succeed(let user):
                Offline.encode(user, key: .currentUser)
                if vm.neetToPop != 0 {
                    popVC(vm.neetToPop + 1)
                } else {
                    let tabBarVC = TabBarVC.asVC()
                    pushVC(tabBarVC)
                }
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}
