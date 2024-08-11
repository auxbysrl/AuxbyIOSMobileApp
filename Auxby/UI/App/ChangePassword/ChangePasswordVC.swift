//
//  ChangePasswordVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.12.2022.
//

import UIKit
import L10n_swift

class ChangePasswordVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var oldPasswordInput: InputFieldView!
    @IBOutlet private weak var newPasswordInput: InputFieldView!
    @IBOutlet private weak var confirmPasswordInput: InputFieldView!
    @IBOutlet private weak var infoLogo: UIImageView!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var requiersSV: UIStackView!
    @IBOutlet private weak var saveButton: MainButtonView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Public properties
    var vm = ChangePasswordVM()
    var indicator: ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
}

private extension ChangePasswordVC {
    
    func setView() {
        scrollView.setBottomConstraintToTopOfKeyboard()
        oldPasswordInput.set(type: .password(.current), hideError: true, returnKey: .next) { [unowned self] in
            newPasswordInput.focus()
        }
        newPasswordInput.set(type: .password(.newChangePassword), hideError: true, returnKey: .next) {
            [unowned self] in
            confirmPasswordInput.focus()
        }
        confirmPasswordInput.set(type: .password(.confirm), hideError: true, returnKey: .done)
        
        saveButton.set(title: "confirmPassword".l10n()) {
            self.vm.changePassword()
        }
    }
    
    func setObservable() {
        vm.$getChangeStatus.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                popVC()
            case .failed(let err):
                print(err.localizedDescription)
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }            default:
                break
            }
        }.store(in: &vm.cancellables)
        
        oldPasswordInput.textPublisher.sink { [unowned self] textValue in
            vm.oldPassword = textValue ?? ""
            setNextButton()
            setInfoImageOld()
        }.store(in: &vm.cancellables)
        
        newPasswordInput.textPublisher.sink { [unowned self] textValue in
            vm.newPassword = textValue ?? ""
            setNextButton()
            setInfoImageNew()
        }.store(in: &vm.cancellables)
        
        confirmPasswordInput.textPublisher.sink { [unowned self] textValue in
            vm.confirmPassword = textValue ?? ""
            setNextButton()
            setInfoConfirm()
        }.store(in: &vm.cancellables)
    }
    
    func setNextButton() {
        let allInputs = [oldPasswordInput, newPasswordInput, confirmPasswordInput].compactMap { $0 as? InputValidationProtocol}
        saveButton.isActive = allInputs.areValid && vm.confirmPassword == vm.newPassword
    }
    
    func setInfoImageOld() {
        if !oldPasswordInput.isValid {
            infoLogo.image = UIImage(named: "invalidLogo")
            errorLabel.text = "passwordHasToInclude".l10n()
            requiersSV.isHidden = false
        } else {
            errorLabel.text = "passwordHasToInclude".l10n()
            infoLogo.image = UIImage(named: "infoLogo")
            requiersSV.isHidden = false
        }
    }
    
    func setInfoImageNew() {
        if !newPasswordInput.isValid {
            errorLabel.text = "passwordHasToInclude".l10n()
            infoLogo.image = UIImage(named: "invalidLogo")
            requiersSV.isHidden = false
        } else {
            errorLabel.text = "validPassword".l10n()
            infoLogo.image = UIImage(named: "validLogo")
            requiersSV.isHidden = true
        }
    }
    
    func setInfoConfirm() {
        if confirmPasswordInput.isValid {
            if vm.confirmPassword == vm.newPassword {
                errorLabel.text = "validPassword".l10n()
                infoLogo.image = UIImage(named: "validLogo")
                requiersSV.isHidden = true
            } else {
                errorLabel.text = "samePasswords".l10n()
                infoLogo.image = UIImage(named: "invalidLogo")
                requiersSV.isHidden = true
            }
        } else {
            errorLabel.text = "passwordHasToInclude".l10n()
            infoLogo.image = UIImage(named: "invalidLogo")
            requiersSV.isHidden = false
        }
    }
}
