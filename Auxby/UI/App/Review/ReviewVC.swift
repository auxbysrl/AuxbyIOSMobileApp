//
//  ReviewVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 13.03.2023.
//

import UIKit
import L10n_swift

class ReviewVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var reviewView: UIView!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet weak var sendButton: MainButtonView!
    
    // MARK: - Public properties
    var vm: ReviewVM!
    var indicator: ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        dismissVC()
    }
    
    @IBAction func selectStar(_ sender: UIButton) {
        stars.forEach {
            let name = $0.tag <= sender.tag ? "starFilled" : "star"
            $0.image = UIImage(named: name)
        }
        vm.rating = sender.tag
    }
}

private extension ReviewVC {
    func setView() {
        hideKeyboardWhenTappedAround()
        delay(0.1) {
            self.reviewView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        }
        sendButton.set(title: "send".l10n()) { [unowned self] in
            vm.rateUser()
        }
        
        setObservable()
    }
    
    func setObservable() {
        vm.$getRatingState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                presentVC(CongratsVC.asVC())
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
            default: break
            }
        }.store(in: &vm.cancellables)
    }
}
