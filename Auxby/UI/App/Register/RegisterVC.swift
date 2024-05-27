//
//  RegisterVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 18.10.2022.
//

import UIKit
import L10n_swift

class RegisterVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var cityInput: InputFieldView!
    @IBOutlet private weak var countryInput: InputFieldView!
    @IBOutlet private weak var phoneInput: InputFieldView!
    @IBOutlet private weak var emailInput: InputFieldView!
    @IBOutlet private weak var firstNameInput: InputFieldView!
    @IBOutlet private weak var lastNameInput: InputFieldView!
    @IBOutlet private weak var mainButton: MainButtonView!
    @IBOutlet private weak var scrollView: UIScrollView!
    

    // MARK: - Public properties
    var vm: RegisterVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func goToHome(_ sender: UIButton) {
        if vm.isFromOmbording {
            let tabBarVC = TabBarVC.asVC()
            pushVC(tabBarVC)
        } else {
            popVC(vm.needToPop)
        }
       
    }
    
    @IBAction func goToLogin(_ sender: UIButton) {
        if vm.needToPop == 2 {
            popVC()
        } else {
            let loginVC = LoginVC.asVC() as! LoginVC
            loginVC.vm.needToPop = 2
            pushVC(loginVC)
        }
    }
}

private extension RegisterVC {
    func setView() {
        firstNameInput.set(type: .stringNamed("firstName".l10n()), placeholder: "firstName".l10n(), shouldBeUpper: true, returnKey: .next, keyboardNextAction: lastNameInput.focus)
        lastNameInput.set(type: .stringNamed("lastName".l10n()), placeholder: "lastName".l10n(), shouldBeUpper: true, returnKey: .next, keyboardNextAction: emailInput.focus)
        emailInput.set(type: .email, placeholder: "email".l10n(), returnKey: .next, keyboardNextAction: phoneInput.focus)
        phoneInput.set(type: .phoneNumber, placeholder: "phoneNumber".l10n(), returnKey: .next, keyboardNextAction: countryInput.focus)
        countryInput.set(type: .stringNamed("country".l10n()), canBeEmpty: true, placeholder: "country".l10n(), shouldBeUpper: true, returnKey: .next, keyboardNextAction: cityInput.focus)
        cityInput.set(type: .stringNamed("city".l10n()), canBeEmpty: true, placeholder: "city".l10n(), shouldBeUpper: true, returnKey: .done)
        mainButton.set(title: "next".l10n()) {
            self.mainButton.startAnimation()
            self.vm.checkEmail()
        }
        scrollView.setBottomConstraintToTopOfKeyboard()
    }
    
    func setObservable() {
        firstNameInput.textPublisher.sink { [unowned self] textValue in
            vm.user.firstName = textValue!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        lastNameInput.textPublisher.sink { [unowned self] textValue in
            vm.user.lastName = textValue!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        phoneInput.textPublisher.sink { [unowned self] textValue in
            vm.user.phone = textValue!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        emailInput.textPublisher.sink { [unowned self] textValue in
            vm.user.email = textValue!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        countryInput.textPublisher.sink { [unowned self] textValue in
            vm.user.address.country = textValue!
        }.store(in: &vm.cancellables)
        
        cityInput.textPublisher.sink { [unowned self] textValue in
            vm.user.address.city = textValue!
        }.store(in: &vm.cancellables)
        
        vm.$checkEmailState.sink { [unowned self] state in
            switch state {
            case .succeed(let exist):
                if exist == true {
                    emailInput.setInvalid(message: "usedEmail".l10n())
                    mainButton.stopAnimation(animationStyle: .shake)
                } else {
                    mainButton.stopAnimation()
                    let createPasswordVC = CreatePasswordVC.asVC() as! CreatePasswordVC
                    createPasswordVC.vm = self.vm
                    pushVC(createPasswordVC)
                }
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
                
            }
        }.store(in: &vm.cancellables)
    }
    
    func setNextButton() {
        let allInputs = [firstNameInput, emailInput, phoneInput].compactMap { $0 as? InputValidationProtocol }
        mainButton.isActive = allInputs.areValid
    }
}
