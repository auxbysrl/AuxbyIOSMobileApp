//
//  TabBarVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 25.10.2022.
//

import UIKit
import L10n_swift
import Combine

class TabBarVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private  var tabBarButtons: [UIButton]!
    
    // MARK: - Public properties
    private(set) static var instance: TabBarVC!
    var vm = TabBarVM()
    
    // MARK: - Private properties
    private(set) var insertedVC: UIViewController!
    private var indicator: ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Offline.encode(true, key: .shouldReloadProfilePicture)
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    // MARK: - IBActions
    @IBAction func selectTab(_ sender: UIButton) {
        guard let identifier = sender.accessibilityIdentifier else { return }
        guard let item = TabBarItem(string: identifier) else { return }
        insertVC(item)
        vm.selectedTag = sender.tag
        selectTag(sender.tag)
    }
    
    @IBAction func addnewOfferAction(_ sender: Any) {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            if let newCat = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
                presentCategories(newCategories: newCat)
            }
        } else {
            presentVC(GuestModeVC.asVC())
        }
    }
    
    private func presentCategories(newCategories: [CategoryDetails]) {
        guard let categoriesVC = CategoriesVC.asVC() as? CategoriesVC else { return }
        categoriesVC.vm.shouldUseCategoryDetails = true
        categoriesVC.vm.categoriesDetails = newCategories
        categoriesVC.vm.filtredCategoriesDetails = newCategories
        pushVC(categoriesVC)
    }
    
    func goToChat() {
        selectTab(tabBarButtons.first(where: { $0.tag == TabBarItem.chat.tag})!)
    }
}
private extension TabBarVC {
    func setView() {
        TabBarVC.instance = self
        selectTab(tabBarButtons.first(where: { $0.tag == vm.selectedTag})!)
        NotificationCenter.default.addObserver(
            self, selector: #selector(onLanguageChanged), name: .L10nLanguageChanged, object: nil
        )
    }
    
    func selectTag(_ tag: Int) {
        tabBarButtons.forEach {
            let imageName = $0.tag != tag ? $0.accessibilityIdentifier! : "\($0.accessibilityIdentifier!)Selected"
            $0.setImage(UIImage(named: imageName), for: .normal)
        }
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
        TabBarItem.reset()
    }
    
    func insertVC(_ item: TabBarItem) {
        if insertedVC != item.vc {
            // remove subviews only when a different tab was selected
            containerView.subviews.forEach { $0.removeFromSuperview() }
        }
        // if the same tab is selected and the inserted view controller has its own navigation controller,
        // pop the last controller if is available (the same behaviour as the UITabBarController has)
        if insertedVC == item.vc, let nav = item.vc as? UINavigationController {
            nav.viewControllers.last?.popVC()
        }
        addChildVC(item.vc, toView: containerView)
        insertedVC = item.vc
    }
}
