//
//  ProfileVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.11.2022.
//

import UIKit
import L10n_swift
import SDWebImage

class ProfileVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private var profileLabels: [UILabel]!
    @IBOutlet private var saveButtons: [MainButtonView]!
    @IBOutlet private var editButtons: [UIButton]!
    @IBOutlet private var editProfieSVs: [UIStackView]!
    @IBOutlet private var labelsTypes: [UILabel]!
    @IBOutlet private weak var firstNameInput: InputFieldView!
    @IBOutlet private weak var lastNameInput: InputFieldView!
    @IBOutlet private weak var phoneInput: InputFieldView!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var countryInput: InputFieldView!
    @IBOutlet private weak var cityInput: InputFieldView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet weak var alert: AlertView!
    @IBOutlet private weak var changePasswordButton: UIButton!
    
    // MARK: - Public properties
    var vm = ProfileVM()
    
    // MARK: - Private properties
    var indicator: ActivityIndicator?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = Offline.currentUser {
            
        } else {
            popVC()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }


    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
        if vm.isEditing {
            view.endEditing(true)
            resetUser()
            
        }
        vm.isEditing.toggle()
        let name = vm.isEditing ? "cancel".l10n() : "edit".l10n()
        editButtons.first { $0.tag == sender.tag
        }?.setTitle(name, for: .normal)
        profileLabels.first { $0.tag == sender.tag
        }?.isHidden = vm.isEditing
        editProfieSVs.first { $0.tag == sender.tag
        }?.isHidden = !vm.isEditing
        setDisable(senderTag: sender.tag, isEnable: vm.isEditing)
       
    }
    
    @IBAction func more(_ sender: UIButton) {
        var actions: [UIAlert.Option] = []
        actions.append(UIAlert.Option(title: "logout".l10n(),action: {
            self.vm.logout()
        }))
        actions.append(UIAlert.Option(title: "deleteAccount".l10n(),action: {
            self.alert.isHidden = false
        }, style: .destructive))
        UIAlert.showActionSheet(options: actions, iPadSourceView: moreButton)
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        let imagePicker = ImagePicker()
        imagePicker.selectedImage = { [weak self] photo in
            self?.vm.updateUserImage(photo: photo)
        }
        imagePicker.show(self, iPadSourceView: self.profileImage)
    }
    
    @IBAction func goToChangePassword(_ sender: UIButton) {
        let changePasswordVC = ChangePasswordVC.asVC()
        pushVC(changePasswordVC)
    }
    
    
}
private extension ProfileVC {
    func setView() {
        self.hideKeyboardWhenTappedAround()
        scrollView.setBottomConstraintToTopOfKeyboard()
        setChangePasswordButton()
        setProfilePhoto()
        setFullName()
        setEmail()
        setPhone()
        setAdress()
        setSaveButtons()
        setObservable()
        setObserveInputs()
        alert.setDelete(title: "areYouSureDelete".l10n(), content: "areYouSureDelete2".l10n(), secondButtonTitle: "confirm".l10n())
        alert.confirm = { [unowned self] in
            alert.isHidden = true
            vm.deleteUser()
        }
        alert.cancel = { [unowned self] in
            alert.isHidden = true
        }
        vm.finishAddingImage = {[unowned self] in
            indicator?.hide()
            indicator = nil
        }
        
        vm.startAddingImage = { [unowned self] in
            indicator = ActivityIndicator()
        }
    }
    
    func setObserveInputs() {
        firstNameInput.textPublisher.sink { [unowned self] text in
            vm.user.firstName = text!
        }.store(in: &vm.cancellables)
        
        lastNameInput.textPublisher.sink { [unowned self] text in
            vm.user.lastName = text!
        }.store(in: &vm.cancellables)
        
        phoneInput.textPublisher.sink { [unowned self] text in
            vm.user.phone = text!
        }.store(in: &vm.cancellables)
        
        countryInput.textPublisher.sink { [unowned self] text in
            vm.user.address.country = text!
        }.store(in: &vm.cancellables)
        
        cityInput.textPublisher.sink { [unowned self] text in
            vm.user.address.city = text!
        }.store(in: &vm.cancellables)
    }
    
    func resetUser() {
        if let user = Offline.decode(key: .currentUser, type: User.self) {
            vm.user = user
        }
        resetUserData()
    }
    
    func setChangePasswordButton() {
        changePasswordButton.isHidden = vm.user.isGoogleAccount
    }
    
    func resetUserData() {
        profileLabels.first { $0.tag == 0
        }?.text = vm.user.firstName + " " + vm.user.lastName
        firstNameInput.setText(text: vm.user.firstName)
        lastNameInput.setText(text: vm.user.lastName)
        
        profileLabels.first { $0.tag == 2
        }?.text = vm.user.phone
        phoneInput.setText(text: vm.user.phone)
        
        profileLabels.first { $0.tag == 3
        }?.text = vm.user.address.country + " " + vm.user.address.city
        countryInput.setText(text: vm.user.address.country)
        cityInput.setText(text: vm.user.address.city)
        if let imageURL = vm.user.avatar {
            if let shouldReload = Offline.decode(key: .shouldReloadProfilePicture, type: Bool.self) {
                if shouldReload {
                    profileImage.setImage(from: imageURL, reload: shouldReload)
                    Offline.encode(false, key: .shouldReloadProfilePicture)
                } else {
                    profileImage.setImage(from: imageURL)
                }
            }
        } else {
            profileImage.image = UIImage(named: User.noProfilePhoto)
        }
        
    }
    
    func setObservable() {
        
        vm.$getLogoutState.sink { [unowned self] state in
            switch state {
            case .succeed:
                Offline.delete(key: .currentUser)
                Offline.delete(key: .favorites)
                Offline.delete(key: .offers)
                Offline.delete(key: .userOffers)
                Keychain.deleteAll()
                NotifyCenter.post(.noUser)
                popVC()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserState.sink { [unowned self] state in
            switch state {
            case .succeed(let user):
                vm.user = user
                resetUserData()
                Offline.encode(user, key: .currentUser)
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$updateUserState.sink { [unowned self] state in
            switch state {
            case .succeed(let user):
                saveButtons.forEach { button in
                    button.stopAnimation()
                }
                editProfile(self.editButtons.first(where: {
                    $0.tag == vm.lastTag
                })!)
                vm.user = user
                Offline.encode(user, key: .currentUser)
                resetUserData()
            case .failed(let err):
                guard let jsonData = err.localizedDescription.data(using: .utf8) else {
                    fatalError("Failed to convert JSON string to Data.")
                }

                do {
                    // Parse the JSON data
                    if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let errors = json["errors"] as? [String],
                       let errorMessage = errors.first {
                        print(errorMessage) // Output: Invalid phone number.
                        UIAlert.showOneButton(message: errorMessage)
                    } else {
                        print("Invalid JSON format or missing error message.")
                    }
                } catch {
                    print("Failed to parse JSON: \(error.localizedDescription)")
                }
                saveButtons.forEach { button in
                    button.stopAnimation()
                }
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getDeleteUser.sink { [unowned self] state in
            switch state {
            case .succeed:
                Offline.delete(key: .currentUser)
                Offline.delete(key: .favorites)
                Offline.delete(key: .offers)
                Offline.delete(key: .userOffers)
                Keychain.deleteAll()
                NotifyCenter.post(.noUser)
                self.popVC()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
    }
    
    func setProfilePhoto() {
        if let imageURL = vm.user.avatar {
            if let shouldReload = Offline.decode(key: .shouldReloadProfilePicture, type: Bool.self) {
                if shouldReload {
                    profileImage.setImage(from: imageURL, reload: shouldReload)
                    Offline.encode(false, key: .shouldReloadProfilePicture)
                } else {
                    profileImage.setImage(from: imageURL)
                }
            }
        } else {
            profileImage.image = UIImage(named: User.noProfilePhoto)
        }
    }
    
    func setFullName() {
        profileLabels.first { $0.tag == 0
        }?.text = vm.user.firstName + " " + vm.user.lastName
        firstNameInput.set(type: .stringNamed("firstName".l10n()), text: vm.user.firstName, shouldBeUpper: true, returnKey: .next, keyboardNextAction: lastNameInput.focus, textSize: 12)
        lastNameInput.set(type: .stringNamed("lastName".l10n()), text: vm.user.lastName, shouldBeUpper: true, returnKey: .done, textSize: 12)
    }
    
    func setEmail() {
        profileLabels.first { $0.tag == 1
        }?.text = vm.user.email
    }
    
    func setPhone() {
        profileLabels.first { $0.tag == 2
        }?.text = vm.user.phone
        phoneInput.set(type: .phoneNumber, text: vm.user.phone, textSize: 12)
    }
    
    func setAdress() {
        profileLabels.first { $0.tag == 3
        }?.text = vm.user.address.country + " " + vm.user.address.city
        countryInput.set(type: .stringNamed("country".l10n()), text: vm.user.address.country, shouldBeUpper: true, returnKey: .next, keyboardNextAction: cityInput.focus, textSize: 12)
        cityInput.set(type: .stringNamed("city".l10n()), text: vm.user.address.city, shouldBeUpper: true, returnKey: .done, textSize: 12)
    }
    
    func setSaveButtons() {
        saveButtons.forEach { [unowned self] button in
            button.set(title: "save".l10n()) {
                button.startAnimation()
                self.vm.updateUser()
                self.vm.lastTag = button.tag
            }
        }
    }
    
    func setDisable(senderTag: Int, isEnable: Bool) {
        editButtons.forEach {
            if isEnable {
                let color: UIColor = $0.tag == senderTag ? .primaryLight : .textDark
                $0.setTitleColor(color, for: .normal)
                $0.isUserInteractionEnabled = $0.tag == senderTag
            } else {
                $0.isUserInteractionEnabled = true
                $0.setTitleColor(.primaryLight, for: .normal)
            }
        }
        
        labelsTypes.forEach {
            if isEnable {
                $0.textColor = $0.tag == senderTag ? .primaryLight : .textDark
            } else {
                $0.textColor = .primaryLight
            }
        }
        
        changePasswordButton.isUserInteractionEnabled = !isEnable
        changePasswordButton.titleLabel?.textColor = isEnable ? .textDark : .primaryLight
    }
}
