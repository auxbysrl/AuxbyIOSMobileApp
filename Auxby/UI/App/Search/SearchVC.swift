//
//  SearchVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 29.06.2023.
//

import UIKit
import L10n_swift

class SearchVC: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var cv: UICollectionView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var noSearch: UIView!
    @IBOutlet weak var noResults: UIView!
    @IBOutlet weak var searcedCV: UICollectionView!
    @IBOutlet weak var resultsLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var searchedView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var noOffersSecondLabel: UILabel!
    
    // MARK: - Public properties
    var vm = SearchVM()
    var indicator: ActivityIndicator?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - IBActions
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func goToFilters(_ sender: UIButton) {
        let filterVC = FilterVC.asVC() as! FilterVC
        if let cat = vm.selectedCategory {
            filterVC.vm = FilterVM(category: cat, text: vm.serchedText)
        } else {
            if vm.isSubcategory {
                if let categories = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
                    if let cat = categories.first(where: { $0.subcategories.contains { $0.id == vm.selectedCategoryId
                    } }) {
                        filterVC.vm = FilterVM(category: cat, text: vm.serchedText)
                    }
                }
            } else {
                filterVC.vm = FilterVM(text: vm.serchedText)
            }
        }
        presentVC(filterVC)
    }
}

// MARK: - Private Methods
private extension SearchVC {
    func setView() {
        searchTextField.becomeFirstResponder()
        hideKeyboardWhenTappedAround()
        cv.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        setObservable()
    }
    
    func setObservable() {
        vm.$getSearchPerCategory.sink { [unowned self] state in
            switch state {
            case .succeed(let result):
                noSearch.isHidden = true
                vm.resultOfSearch = result
                if result.categoryResult.isEmpty {
                    noOffersSecondLabel.text = "\("noResults2".l10n())\(vm.serchedText)\n\("noResults3".l10n())"
                    noResults.isHidden = false
                    vm.resultOfSearch = nil
                    cv.reloadData()
                } else {
                    noResults.isHidden = true
                    cv.reloadData()
                }
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                print(err.localizedDescription)
            default: break
                
            }
        }.store(in: &vm.cancellables)
        
        vm.$getSearchState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let offers):
                if !offers.isEmpty {
                    vm.searchedOffers = offers
                    resultsLabel.text = "\( vm.searchedOffers.count) \("resultsIn".l10n())"
                    cv.isHidden = true
                    filterButton.isHidden = false
                    searcedCV.reloadData()
                    searchedView.isHidden = false
                }
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }                
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        NotifyCenter.observable(for: .filterOffers).sink { [unowned self]  in
            if let offers = Offline.decode(key: .filteredOffers, type: [Offer].self) {
                vm.searchedOffers = offers
                resultsLabel.text = "\( vm.searchedOffers.count) \("resultsIn".l10n())"
                searcedCV.reloadData()
                if let search = Offline.decode(key: .currentSearch, type: SearchWithFilter.self) {
                    if search.categories.isEmpty {
                        categoryLabel.text =  "allCategories".l10n()
                    } else {
                        if let categories = Offline.decode(key: .categories, type: [Category].self) {
                            if let selectedCategory = categories.first(where: { $0.id == search.categories.first }) {
                                categoryLabel.text = selectedCategory.label.first(where: { $0.language == L10n.shared.language
                                })?.translation ?? "allCategories".l10n()
                            }
                        }
                        
                    }
                }
            }
        }.store(in: &vm.cancellables)
    }
}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        if textField.text?.count ?? 0 >= 3 {
            vm.searchOffers(search: SearchByCategory(categories: [], title: textField.text ?? ""))
            Offline.delete(key: .currentSearch)
            categoryLabel.text = "allCategories".l10n()
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        vm.serchedText = textField.text ?? ""
        searchedView.isHidden = true
        filterButton.isHidden = true
        vm.selectedCategory = nil
        vm.isSubcategory = false
        cv.isHidden = false
        if textField.text!.count >= 3 {
            vm.searchPerCategory(text: textField.text ?? "")
            Offline.delete(key: .currentSearch)
        } else {
            vm.resultOfSearch = nil
            cv.reloadData()
            noSearch.isHidden = false
            noResults.isHidden = true
        }
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == cv {
            return vm.resultOfSearch?.categoryResult.count ?? 0
        } else {
            return vm.searchedOffers.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == cv {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchCVCell.className, for: indexPath) as! SearchCVCell
            let categoryId = Int(Array(vm.resultOfSearch!.categoryResult.keys.sorted(by: { Int($0)! < Int($1)!
            }))[indexPath.row])
            let numberOfResults = vm.resultOfSearch!.categoryResult["\(categoryId!)"]
            //let numberOfResults = Int(Array(vm.resultOfSearch!.categoryResult.values)[indexPath.row])
            let categories = Offline.decode(key: .categories, type: [Category].self) ?? []
            let categoriesDetails = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self)
            var categoryOfSearch = categories.first
            for category in categories {
                if let cat = categoriesDetails?.first(where: {$0.id == category.id})?.subcategories.first(where: {$0.id == categoryId }) {
                    categoryOfSearch = cat.toCategory()
                } else if category.id == categoryId {
                    categoryOfSearch = category
                }
            }
            
            cell.setCell(search: vm.serchedText, category: categoryOfSearch!, numberOfSearch: numberOfResults!)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OfferCell.className, for: indexPath) as! OfferCell
        cell.setCell(offer:  vm.searchedOffers[indexPath.row], addToFav: { [unowned self] in
            if Offline.currentUser != nil {
                let offer =  vm.searchedOffers[indexPath.row]
                vm.addOrRemoveFromFavorite(id: offer.id)
            }
        }, viewOffers: nil, showUsers: nil)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == cv {
            let categoryId = Int(Array(vm.resultOfSearch!.categoryResult.keys.sorted(by: { Int($0)! < Int($1)!
            }))[indexPath.row])
            vm.selectedCategoryId = categoryId!
            let categories = Offline.decode(key: .categories, type: [Category].self) ?? []
            let categoriesDetails = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self)
            var categoryOfSearch = categories.first
            for category in categories {
                if let cat = categoriesDetails?.first(where: {$0.id == category.id})?.subcategories.first(where: {$0.id == categoryId }) {
                    categoryOfSearch = cat.toCategory()
                    vm.isSubcategory = true
                } else if category.id == categoryId {
                    categoryOfSearch = category
                    vm.isSubcategory = false
                }
            }
            
            vm.selectedCategory = categoriesDetails?.first(where: { $0.id == categoryOfSearch?.id })
            vm.searchOffers(search: SearchByCategory(categories: [categoryOfSearch!.id], title: vm.serchedText))
            
            categoryLabel.text = categoryOfSearch!.label.first(where: { $0.language == L10n.shared.language
            })?.translation ?? "allCategories".l10n()
        } else {
            let offerDetailsVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            offerDetailsVC.vm = PreviewOrDetailsVM(offer:  vm.searchedOffers[indexPath.row])
            pushVC(offerDetailsVC)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == cv {
           return CGSize(width: collectionView.frame.width, height: 63)
        } else {
           return CGSize(width: UIScreen.main.bounds.width - 32, height: 280)
        }
    }
}

