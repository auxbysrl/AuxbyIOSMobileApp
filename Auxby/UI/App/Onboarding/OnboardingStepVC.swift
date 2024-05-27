//
//  OnboardingCell.swift
//  Auxby
//
//  Created by Andrei Traciu on 19.10.2022.
//

import UIKit

class OnboardingStepVC: UIViewController {
    
    static let identifier = "OnboardingCell"
    
    // MARK: IBOutlets
    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var stepSubtitleLbl: UILabel!
    @IBOutlet weak var stepDescriptionLbl: UILabel!
    
    // MARK: Public Properties
    var pageIndex: Int = 0
    var currentStep: OnboardingVC.Steps = .step1
    
    // MARK: Overriden Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupVC(step: currentStep)
    }

    // MARK: Public Methods
    private func setupVC(step: OnboardingVC.Steps) {
        stepImage.image = UIImage(named: step.imageName)
        stepSubtitleLbl.text = step.subtitle
        stepDescriptionLbl.text = step.description
    }
}
