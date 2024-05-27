//
//  CategoriesVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 15.11.2022.
//

import UIKit
import L10n_swift
import Combine

class CategoriesVC: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var cv: UICollectionView!
    @IBOutlet weak var categoriesTitle: UILabel!
    @IBOutlet weak var selectCategoryLAbel: UILabel!
    @IBOutlet weak var searchView: UIView!
    
    // MARK: - Public properties
    var vm = CategoriesVM()
    var cancellables: Set<AnyCancellable> = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }

    // MARK: - IBActions
    @IBAction func back(_ sender: Any) {
        if isModal {
            dismissVC()
        } else {
            popVC()
        }
    }
    
    @IBAction func search(_ sender: UITextField) {
        if sender.text?.isEmpty == false && sender.text?.count ?? 0 > 1 {
            vm.filterCategories(name: sender.text ?? "")
        } else {
            vm.filtredCategories = vm.categories
            vm.filtredCategoriesDetails = vm.categoriesDetails
        }
        cv.reloadData()
    }
    
    fileprivate func presentNewOffer(category: CategoryDetails) {
        guard let addOfferVC = AddOffersVC.asVC(storyboardName: "Offers") as? AddOffersVC else { return }
        addOfferVC.vm = AddOfferVM(category: category)
        pushVC(addOfferVC)
    }
}
private extension CategoriesVC {
    func setView() {
        searchView.isHidden = vm.shouldUseCategoryDetails
        selectCategoryLAbel.isHidden = !vm.shouldUseCategoryDetails
        categoriesTitle.text = vm.shouldUseCategoryDetails ? "addOffer_screen_title".l10n() : "categories".l10n()
        selectCategoryLAbel.text = "selectCat".l10n()
        searchTextField.returnKeyType = .done
        searchTextField.attributedPlaceholder =
        NSAttributedString(string: "searchCategory".l10n(), attributes: [NSAttributedString.Key.foregroundColor : UIColor.textLight])
        cv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setObservable()
    }
    
    func setObservable() {
        NotifyCenter.observable(for: .noUser).sink { [unowned self] _ in
           popVC()
        }.store(in: &cancellables)
    }
}

extension CategoriesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.shouldUseCategoryDetails ? vm.filtredCategoriesDetails.count : vm.filtredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCell.className, for: indexPath) as! CategoryCell
        if vm.shouldUseCategoryDetails {
            cell.setCell(categoryDetails: vm.filtredCategoriesDetails[indexPath.row])
        } else {
            cell.setCell(category: vm.filtredCategories[indexPath.row])
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 92)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if vm.shouldUseCategoryDetails {
            if isModal {
                vm.selectCategoryForFilter?(vm.filtredCategoriesDetails[indexPath.row])
                dismissVC()
            } else {
                presentNewOffer(category: vm.filtredCategoriesDetails[indexPath.row])
            }
        } else {
            let currentCat = vm.categories[indexPath.row]
            if currentCat.noOffers > 0 {
                let offersByCategory = OffersByCategoryVC.asVC() as! OffersByCategoryVC
                offersByCategory.vm = OffersByCategoryVM(selectedCategory: vm.categories[indexPath.row])
                topVC().pushVC(offersByCategory)
            }
        }
    }
}
