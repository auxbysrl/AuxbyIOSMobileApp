//
//  CongratsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.03.2023.
//

import UIKit
import L10n_swift

class CongratsVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var congratsView: UIView!
    @IBOutlet weak var closeButton: MainButtonView!
    
    var back: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismissVC {
            self.back?()
        }
    }
    
}

private extension CongratsVC {
    func setView() {
        delay(0.1) {
            self.congratsView.roundCorners(corners: [.topLeft, .topRight], radius: 25)
        }
        closeButton.set(title: "close".l10n()) {
            self.dismissVC {
                self.back?()
            }
        }
    }
}
