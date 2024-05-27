//
//  SplashVC.swift
//  Auxby
//
//  Created by Andrei Traciu on 11.10.2022.
//

import UIKit
import NVActivityIndicatorView
import Combine

class SplashVC: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var loaderView: NVActivityIndicatorView!
    
    // MARK: - Private properties
    private var cancellables: Set<AnyCancellable> = []

    // MARK: Overriden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoader()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentNextScreen()
    }
    
}

private extension SplashVC {
    func presentNextScreen() {
        let onboardingSeen = Offline.decode(key: .onboardingSeen, type: Bool.self) == true
        delay(0.3) {
            self.pushVC(onboardingSeen ? TabBarVC.asVC() : OnboardingVC.asVC())
        }
    }
    
    func setupLoader() {
        loaderView.type = .pacman
        loaderView.backgroundColor = .clear
        loaderView.color = .secondary
        loaderView.startAnimating()
    }
}
