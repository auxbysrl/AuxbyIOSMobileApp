//
//  ForgotPasswordVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.10.2022.
//

import UIKit
import Combine
import L10n_swift

class ForgotPasswordVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var emailInput: InputFieldView!
    @IBOutlet private weak var mainButton: MainButtonView!
    
    // MARK: - Public properties
    var cancellables: Set<AnyCancellable> = []
    var vm = ForgotPasswordVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func goToLogin(_ sender: UIButton) {
        popVC()
    }
    
    
    @IBAction func goToHome(_ sender: UIButton) {
        let tabBarVC = TabBarVC.asVC()
        pushVC(tabBarVC)
    }
}

private extension ForgotPasswordVC {
    func setView() {
        emailInput.set(type: .email, placeholder: "email".l10n(), returnKey: .done)
        mainButton.set(title: "sendResetLink".l10n()) {
            self.mainButton.startAnimation()
            self.vm.forgotPassword()
        }
    }
    
    func setObservable() {
        emailInput.textPublisher.sink { [unowned self] textValue in
            vm.email = textValue
            mainButton.isActive = emailInput.isValid
        }.store(in: &cancellables)
        
        vm.$forgotPasswordState.sink { [unowned self] state in
            switch state {
            case .succeed:
                mainButton.stopAnimation()
                UIAlert.showOneButton(message: "instructionsSent".l10n(), butttonTitle: "openMail".l10n()) {
                    self.popVC()
                    let mailURL = URL(string: "message://")!
                    if UIApplication.shared.canOpenURL(mailURL) {
                        UIApplication.shared.open(mailURL)
                    }
                    
                }
            case.failed(let err):
                mainButton.stopAnimation(animationStyle: .shake)
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}
