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
    @IBOutlet weak var addView: AddView!
    
    // MARK: - Public properties
    private(set) static var instance: TabBarVC!
    var vm = TabBarVM()
    
    // MARK: - Private properties
    private(set) var insertedVC: UIViewController!
    private var indicator: ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        setObservable()
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
        delay(5) {
            self.vm.getAdd()
        }
    }
    
    func displayAdd(_ add: AddDetails) {
        addView.set(content: add.add.text, imageURL: add.add.image, showAdd: add.add.categoryId != nil)
        addView.isHidden = add.hasSeen
        addView.goToAdd = { [unowned self] in
            addView.isHidden = true
            if let _ = Offline.currentUser {
                add.hasSeen = true
                Offline.encode(add, key: .currentAdd)
                if let categoryId = add.add.categoryId {
                    if let currentCategories = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self), let index = currentCategories.firstIndex(where: {  $0.id == categoryId }) {
                        guard let addOfferVC = AddOffersVC.asVC(storyboardName: "Offers") as? AddOffersVC else { return }
                        addOfferVC.vm = AddOfferVM(category: currentCategories[index])
                        pushVC(addOfferVC)
                    }
                }
            } else {
                presentVC(GuestModeVC.asVC())
            }
           
        }
        addView.close = { [unowned self] in
            addView.isHidden = true
        }
    }
    
    func setObservable() {
        vm.$getAddState.sink { [unowned self] state in
            switch state {
            case .succeed(let adds):
                if !adds.isEmpty {
                    if let curentAdd = Offline.decode(key: .currentAdd, type: AddDetails.self) {
                        if curentAdd.add.code == adds[0].code {
                            curentAdd.add.image = adds[0].image
                            curentAdd.add.text = adds[0].text
                            Offline.encode(curentAdd, key: .currentAdd)
                            displayAdd(curentAdd)
                        } else {
                            Offline.encode(AddDetails(add: adds[0]), key: .currentAdd)
                            displayAdd(AddDetails(add: adds[0]))
                        }
                        
                    } else {
                        Offline.encode(AddDetails(add: adds[0]), key: .currentAdd)
                        displayAdd(AddDetails(add: adds[0]))
                    }
                   
                }
            case.failed(let err):
                print(err)
            default: break
            }
        }.store(in: &vm.cancellables)
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
