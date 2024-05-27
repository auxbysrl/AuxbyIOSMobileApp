//
//  GuestModeVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.05.2023.
//

import UIKit

class GuestModeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction func goToRegister(_ sender: UIButton) {
        self.dismissVC() {
            let loginVC = LoginVC.asVC()
            topVC().pushVC(loginVC)
        }
    }
    
    @IBAction func goToLogin(_ sender: UIButton) {
        let loginVC = LoginVC.asVC()
        dismissVC(){
            topVC().pushVC(loginVC)
        }
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismissVC()
    }
}
