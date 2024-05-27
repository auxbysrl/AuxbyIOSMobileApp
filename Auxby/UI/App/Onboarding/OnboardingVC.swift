//
//  OnboardingVC.swift
//  Auxby
//
//  Created by Andrei Traciu on 11.10.2022.
//

import UIKit
import L10n_swift


class OnboardingVC: PageControllerDataSource {
    
    // MARK: IBOutlets
    @IBOutlet weak var pageContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var joinBtn: MainButtonView!
    
    // MARK: Public Properties
    
    // MARK: Private Properties
    let steps = Steps.allCases
    private var pageControl = CHIPageControlAleppo()
    var onboardingSeen = false
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: IBActions
    @IBAction func loginAction(_ sender: Any) {
        let loginVC = LoginVC.asVC() as! LoginVC
        loginVC.vm.isFromObording = true
        Offline.encode(true, key: .onboardingSeen)
        pushVC(loginVC)
    }
    
    @IBAction func skipAction(_ sender: Any) {
        let tabBarVc = TabBarVC.asVC()
        Offline.encode(true, key: .onboardingSeen)
        pushVC(tabBarVc)
    }
    
    // MARK: Private Methods
    private func setupView() {
        setOnboardingPages()
        configurePageControl()
        setupJoinBtn()
    }
    
    private func setOnboardingPages() {
        pageViewController.delegate = self
        var vcs = [UIViewController]()
        for index in 0 ..< steps.count {
            let onboardingPageVC = OnboardingStepVC.asVC(storyboardName: "Onboarding") as! OnboardingStepVC
            onboardingPageVC.currentStep = steps[index]
            onboardingPageVC.pageIndex = index
            vcs.append(onboardingPageVC)
        }
        setPageController(vcs: vcs, containerView: containerView)
    }
    
    private func configurePageControl() {
        pageControl = CHIPageControlAleppo(frame: CGRect(x: 0,
                                                         y: pageContainer.frame.size.height - 15,
                                                         width: UIScreen.main.bounds.width,
                                                         height: 0))
        pageControl.numberOfPages = steps.count
        pageControl.radius = 5
        pageControl.tintColor = .textLight
        pageControl.currentPageTintColor = .secondary
        pageControl.padding = 8
        pageContainer.addSubview(pageControl)
    }
    
    private func setupJoinBtn() {
        changeJoinBtnState(isHidden: true)
        joinBtn.set(title: "join".l10n()) {
            self.joinBtn.startAnimation()
            Offline.encode(true, key: .onboardingSeen)
            delay(0.3) {
                self.joinBtn.stopAnimation(animationStyle: .expand) {
                    let loginVC = LoginVC.asVC() as! LoginVC
                    loginVC.vm.isFromObording = true
                    Offline.encode(true, key: .onboardingSeen)
                    self.pushVC(loginVC)
                }
            }
        }
        self.joinBtn.button.titleLabel?.font = UIFont(name: "Montserrat-SemiBold", size: 16)
    }
    
    private func changeJoinBtnState(isHidden: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.joinBtn.alpha = isHidden ? 0 : 1
            self.joinBtn.isActive = !isHidden
        }
    }
}

extension OnboardingVC: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let vc = pageViewController.viewControllers?.first as? OnboardingStepVC else { return }
        pageControl.set(progress: vc.pageIndex, animated: true)
        if vc.pageIndex == 2 {
            onboardingSeen = true
        }
        goTo(index: vc.pageIndex)
        changeJoinBtnState(isHidden: !onboardingSeen)
    }
}

extension OnboardingVC {
    enum Steps: Int, CaseIterable {
        case step1 = 1
        case step2
        case step3
        
        var title: String {
            return "step".l10n() + "\(rawValue)"
        }
        
        var subtitle: String {
            switch self {
            case .step1: return "search".l10n()
            case .step2: return "bidOrBuy".l10n()
            case .step3: return "win".l10n()
            }
        }
        
        var description: String {
            switch self {
            case .step1: return "registerAndFind".l10n()
            case .step2: return "findTheBest".l10n()
            case .step3: return "winAndEnjoy".l10n()
            }
        }
        
        var imageName: String {
            switch self {
            case .step1: return "step1"
            case .step2: return "step2"
            case .step3: return "step3"
            }
        }
    }
    
}
