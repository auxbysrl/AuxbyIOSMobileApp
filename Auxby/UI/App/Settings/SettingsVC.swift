//
//  SettingsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.12.2022.
//

import UIKit
import L10n_swift

class SettingsVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private var editButtons: [UIButton]!
    @IBOutlet private var editProfieSVs: [UIStackView]!
    @IBOutlet private var profileLabels: [UILabel]!
    @IBOutlet private var labelsTypes: [UILabel]!
    @IBOutlet private weak var dropDown: DropDownView!
    
    // MARK: - Public properties
    var vm = SettingsVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()

    }
    
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func editProfile(_ sender: UIButton) {
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
}

private extension SettingsVC{
    func setView() {
        setProfilePhoto()
        NotificationCenter.default.addObserver(
            self, selector: #selector(onLanguageChanged), name: .L10nLanguageChanged, object: nil
        )
       setDropDown()
    }
    
    @objc func onLanguageChanged() {
        let viewControllers = navigationController?.viewControllers.map { vc -> UIViewController in
            if let storyboard = vc.storyboard, let identifier = vc.restorationIdentifier {
                return storyboard.instantiateViewController(withIdentifier: identifier)
            }
            return vc
        }
        if let viewControllers = viewControllers {
            navigationController?.setViewControllers(viewControllers, animated: false)
        }
    }
    
    func setDropDown() {
        let currentLanguge = L10n.shared.language
        var languages: [String] = []
        Offline.languages.forEach {
            languages.append($0.getCountryFromCode())
        }
        let index = languages.firstIndex(of: currentLanguge.getCountryFromCode())
        dropDown.set(dataSource: languages, selectedIndex: index)
    }
    
    func setProfilePhoto() {
        if let imageURL = vm.user.avatar {
            profileImage.setImage(from: imageURL)
        } else {
            profileImage.image = UIImage(named: User.noProfilePhoto)
        }
        profileLabels.first { $0.tag == 0}?.text = L10n.shared.language.getCountryFromCode()
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
    }
}
