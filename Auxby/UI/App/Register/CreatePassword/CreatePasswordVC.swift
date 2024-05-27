//
//  CreatePasswordVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.10.2022.
//

import UIKit
import L10n_swift

class CreatePasswordVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var passwordInput: InputFieldView!
    @IBOutlet private weak var confirmPasswordInput: InputFieldView!
    @IBOutlet private weak var infoImage: UIImageView!
    @IBOutlet private weak var requirmentsSV: UIStackView!
    @IBOutlet private weak var checkButton: UIButton!
    @IBOutlet private weak var mainButton: MainButtonView!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: - Public properties
    var vm: RegisterVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func goToHome(_ sender: UIButton) {
        let tabBarVC = TabBarVC.asVC()
        pushVC(tabBarVC)
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func checkOrUnchek(_ sender: UIButton) {
        vm.hasAgreed.toggle()
        let imageName = vm.hasAgreed ? "checkmark.square" : "square"
        checkButton.setImage(UIImage(systemName: imageName), for: .normal)
        setNextButton()
    }
    
    @IBAction func goToTerms(_ sender: UIButton) {
        if let url = URL(string: "https://www.auxby.ro/termeni-si-conditii") {
                  if UIApplication.shared.canOpenURL(url) {
                      UIApplication.shared.open(url, options: [:], completionHandler: nil)
                  }
              }
    }
    
    @IBAction func goToLogin(_ sender: UIButton) {
        let loginVC = LoginVC.asVC()
        pushVC(loginVC)
    }
}

private extension CreatePasswordVC {
    
    func setView() {
        scrollView.setBottomConstraintToTopOfKeyboard()
        passwordInput.set(type: .password(.new), hideError: true, returnKey: .next) { [unowned self] in
            confirmPasswordInput.focus()
            confirmPasswordInput.inputIsValid()
            setNextButton()
            setInfoImageConfirm()
        }
        confirmPasswordInput.set(type: .password(.confirm), hideError: true, returnKey: .done)
        mainButton.set(title: "signUp".l10n()) {
            self.vm.register()
        }
    }
    
    func setObservable() {
        passwordInput.textPublisher.sink { [unowned self] textValue in
            vm.password = textValue
            setNextButton()
            setInfoImage()
        }.store(in: &vm.cancellables)
        
        confirmPasswordInput.textPublisher.sink { [unowned self] textValue in
            vm.confirmedPassword = textValue
            setNextButton()
            setInfoImageConfirm()
        }.store(in: &vm.cancellables)
        
        vm.$registerState.sink { [unowned self] state in
            switch state {
            case .loading:
                mainButton.startAnimation()
            case .succeed:
                mainButton.stopAnimation(animationStyle: .expand) {
                    let verifyEmailVC = VerifyEmailVC.asVC() as! VerifyEmailVC
                    verifyEmailVC.vm = VerifyEmailVM(email: self.vm.user.email, password: self.vm.password!)
                    self.pushVC(verifyEmailVC)
                }
            case .failed:
                mainButton.stopAnimation(animationStyle: .shake) {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
            default: break
            }
        }.store(in: &vm.cancellables)
    }
    
    func setNextButton() {
        let allInputs = [passwordInput, confirmPasswordInput].compactMap { $0 as? InputValidationProtocol }
        mainButton.isActive = allInputs.areValid && vm.hasAgreed
    }
    
    func setInfoImage() {
        if !passwordInput.isValid {
            infoImage.image = UIImage(named: "invalidLogo")
            infoLabel.text = "passwordHasToInclude".l10n()
            requirmentsSV.isHidden = false
        } else {
            infoLabel.text = "passwordHasToInclude".l10n()
            infoImage.image = UIImage(named: "infoLogo")
            requirmentsSV.isHidden = false
            
        }
    }
    
    func setInfoImageConfirm() {
        if !confirmPasswordInput.text.isValidPassword {
            infoImage.image = UIImage(named: "invalidLogo")
            infoLabel.text = "passwordHasToInclude".l10n()
            requirmentsSV.isHidden = false
        } else {
            if vm.confirmedPassword != vm.password {
                infoLabel.text = "samePasswords".l10n()
                infoImage.image = UIImage(named: "invalidLogo")
                requirmentsSV.isHidden = true
            } else {
                infoLabel.text = "validPassword".l10n()
                infoImage.image = UIImage(named: "validLogo")
                requirmentsSV.isHidden = true
            }
        }
       
    }
    
}
