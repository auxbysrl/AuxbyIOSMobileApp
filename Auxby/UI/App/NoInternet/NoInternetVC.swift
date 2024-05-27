//
//  NoInternetVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.09.2023.
//

import UIKit
import Reachability

class NoInternetVC: UIViewController {
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        Offline.encode(true, key: .isNoInternetPresented)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Offline.delete(key: .isNoInternetPresented)
    }
}
