//
//  LoginVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import UIKit
import GoogleSignIn
import Combine
import L10n_swift

class LoginVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var emailInput: InputFieldView!
    @IBOutlet private weak var passwordInput: InputFieldView!
    @IBOutlet private weak var mainButton: MainButtonView!
    @IBOutlet private weak var googleLoginView: UIView!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet weak var agreeSV: UIStackView!
    
    // MARK: - Public properties
    var vm = LoginVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func goToTerms(_ sender: UIButton) {
        if let url = URL(string: "https://www.auxby.ro/termeni-si-conditii") {
                  if UIApplication.shared.canOpenURL(url) {
                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
                  }
              }
    }
    
    @IBAction func goToForgot(_ sender: UIButton) {
        let forgotVC = ForgotPasswordVC.asVC()
        pushVC(forgotVC)
    }
    
    @IBAction func goToRegister(_ sender: UIButton) {
        let registerVC = RegisterVC.asVC() as! RegisterVC
        registerVC.vm = RegisterVM(needToPop: 2, isFromOmboarding: vm.isFromObording)
        pushVC(registerVC)
    }
    
    @IBAction func goToHome(_ sender: UIButton) {
        if vm.isFromObording {
            let tabBarVC = TabBarVC.asVC()
            pushVC(tabBarVC)
        } else {
            popVC(vm.needToPop)
        }
    }
    
    @IBAction func checkOrUncheck(_ sender: UIButton) {
        checkButton.tintColor = .textDark
        vm.hasAgreed.toggle()
        let imageName = vm.hasAgreed ? "checkmark.square" : "square"
        checkButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}

private extension LoginVC {
    func setView() {
        self.hideKeyboardWhenTappedAround()
        emailInput.set(type: .email, placeholder: "email".l10n(), returnKey: .next, keyboardNextAction: passwordInput.focus)
        passwordInput.set(type: .password(.password), placeholder: "password".l10n(), returnKey: .done)
        mainButton.set(title: "login".l10n()) {
            self.vm.login()
        }
        
        googleLoginView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSignInButton)))
    }
    
    @objc func handleSignInButton() {
        if vm.hasAgreed {
            GIDSignIn.sharedInstance.signIn(
                withPresenting: self) { signInResult, error in
                    guard let result = signInResult else {
                        // Inspect error
                        return
                    }
                    if let token = result.user.idToken?.tokenString {
                        self.vm.loginGoogle(token: token)
                    }
                }
        } else {
            checkButton.tintColor = .red
            agreeSV.shake()
        }
    }
    func setObservable() {
        let fields: [InputValidationProtocol] = [emailInput, passwordInput]
        Publishers.CombineLatest(emailInput.textPublisher, passwordInput.textPublisher)
            .sink {[unowned self] user, pass in
                vm.email = user
                vm.password = pass
                mainButton.isActive = fields.areValid
            }.store(in: &vm.cancellables)
        
        vm.$loginState.sink { [unowned self] state in
            switch state {
            case .loading:
                mainButton.startAnimation()
            case .succeed(let loginResponse):
                if let token = loginResponse.token {
                    Keychain.save(value: token, item: .token)
                    Keychain.save(value: vm.email!, item: .email)
                }
                vm.saveApns()
                vm.getUser()
            case .failed(let err):
                mainButton.stopAnimation(animationStyle: .shake)
                if err.errorStatus == 423 {
                    UIAlert.showOneButton(message: "notVerified".l10n()) { [unowned self] in
                        let verifyEmailVC = VerifyEmailVC.asVC() as! VerifyEmailVC
                        verifyEmailVC.vm = VerifyEmailVM(email: vm.email!, password: vm.password!, needToPop: vm.needToPop)
                        pushVC(verifyEmailVC)
                    }
                } else if err.errorStatus == 400 {
                    UIAlert.showOneButton(message: "incorectUsername".l10n())
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                
            default : break
            }
        }.store(in: &vm.cancellables)
        
        vm.$loginGoogleState.sink { [unowned self] state in
            switch state {
            case .loading:
                mainButton.startAnimation()
            case .succeed(let loginResponse):
                if let token = loginResponse.token {
                    Keychain.save(value: token, item: .token)
                }
                vm.getUser()
            case .failed (let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                mainButton.stopAnimation(animationStyle: .shake)
                print(err.localizedDescription)
            default : break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserState.sink { [unowned self] state in
            switch state {
            case.succeed(let user):
                Offline.encode(user, key: .currentUser)
                mainButton.stopAnimation(animationStyle: .expand) {
                    if self.vm.isFromObording {
                        let tabBarVC = TabBarVC.asVC()
                        self.pushVC(tabBarVC)
                    } else {
                        delay(0.1) {
                            self.popVC(self.vm.needToPop)
                            NotifyCenter.post(.noUser)
                        }
                    }
                }
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                mainButton.stopAnimation(animationStyle: .shake)
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}
