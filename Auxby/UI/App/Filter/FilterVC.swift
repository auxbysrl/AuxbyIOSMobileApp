//
//  FilterVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 05.07.2023.
//

import UIKit
import L10n_swift

class FilterVC: UIViewController {
    // MARK: - IBOutlets
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var startPriceInput: DropDownWithTextInput!
    @IBOutlet weak var endPriceInput: DropDownWithTextInput!
    @IBOutlet weak var locationDropDown: DropDownView!
    @IBOutlet weak var typeRadioButton: TwoRadioButtonsView!
    @IBOutlet weak var conditionRadioButton: TwoRadioButtonsView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryTitle: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var subcategoryView: UIView!
    @IBOutlet weak var subcategoryCV: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var categoryDetailsStack: UIStackView!
    @IBOutlet weak var addFilter: MainButtonView!
    
    // MARK: - Public properties
    var vm: FilterVM!
    
    // MARK: Private Properties
    private var selectedSubcategory: String = ""
    private var indicator: ActivityIndicator?
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismissVC()
    }
    
    @IBAction func selectCategory(_ sender: UIButton) {
        if vm.category == nil {
            if let newCat = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
                guard let categoriesVC = CategoriesVC.asVC() as? CategoriesVC else { return }
                categoriesVC.vm.shouldUseCategoryDetails = true
                categoriesVC.vm.categoriesDetails = newCat
                categoriesVC.vm.filtredCategoriesDetails = newCat
                categoriesVC.vm.selectCategoryForFilter = { [unowned self] category in
                    vm.category = category
                    vm.subcategories = category.subcategories.map { $0.label.translationText }
                    vm.subcategoriesIds = category.subcategories.map { $0.id }
                    vm.subcategoriesNames = category.subcategories.map { $0.name }
                    vm.parentsOfView = []
                    setInputs()
                    setCategories()
                }
                presentVC(categoriesVC)
            }
        }
    }
    
    @IBAction func removeCategory(_ sender: UIButton) {
        vm.category = nil
        vm.parentsOfView = []
        setInputs()
        setCategories()
    }
    
    @IBAction func clear(_ sender: UIButton) {
        vm.parentsOfView = []
        vm.category = nil
        Offline.delete(key: .currentSearch)
        setInputs()
        setCategories()
    }
    
}

// MARK: - Private Methods
private extension FilterVC {
    func setView() {
        hideKeyboardWhenTappedAround()
        scrollView.setBottomConstraintToTopOfKeyboard()
        delay(0.1) {
            self.topView.roundCorners(corners: [.topLeft,.topRight], radius: 25)
        }
        if let search = Offline.decode(key: .currentSearch, type: SearchWithFilter.self) {
            if let categoryId = search.categories.first {
                if let categories = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
                    vm.category = categories.first(where: { $0.id == categoryId })
                }
            }
        }
        setInputs()
        setCategories()
        setInputsObservable()
        setObservable()
    }
    
    func setObservable() {
        vm.$getSearchState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let offers):
                Offline.encode(offers, key: .filteredOffers)
                NotifyCenter.post(.filterOffers)
                dismissVC()
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
    }
    
    func setInputsObservable() {
        startPriceInput.textPublisher.sink { [unowned self] text in
            vm.startPrice = Double(text ?? "")
        }.store(in: &vm.cancellables)
        
        endPriceInput.textPublisher.sink { [unowned self] text in
            vm.endPrice = Double(text ?? "")
        }.store(in: &vm.cancellables)
    }
    
    func setCategories() {
        if var category = vm.category {
            categoryView.borderWidth = 1
            categoryButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            categoryButton.tintColor = .textLight
            categoryTitle.text = category.label.translationText
            if category.icon.first == "." {
                category.icon.remove(at: category.icon.startIndex)
            }
            categoryImage.setImage(from: category.icon)
            
            subcategoryView.isHidden = vm.subcategories.isEmpty
            if !vm.subcategories.isEmpty {
                selectedSubcategory = vm.subcategoriesNames.first ?? ""
            }
            subcategoryCV.reloadData()
            categoryDetailsStack.isHidden = category.categoryDetails.isEmpty
            createTotalCategoryDetails()
        } else {
            categoryTitle.text = "selectCat".l10n()
            categoryView.borderWidth = 0
            categoryImage.image = UIImage(named: "noCategory")
            categoryButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            categoryButton.tintColor = .textDark
            subcategoryView.isHidden = true
            categoryDetailsStack.isHidden = true
            categoryDetailsStack.removeAllSubviews()
        }
    }
    
    private func createTotalCategoryDetails() {
        categoryDetailsStack.removeAllSubviews()
        createSubCategoryDetails()
        createCategoryDetails()
    }
    
    private func createSubCategoryDetails() {
        let subcategoryList = getSubcategoryItems()
        if subcategoryList.count > 0 {
            let orderedDetails = subcategoryList[0].categoryDetails.sorted { $0.guiOrder < $1.guiOrder }
            for detail in orderedDetails {
                guard let type = AddOfferElement(rawValue: detail.type) else { continue }
                if detail.parent == "" {
                    vm.parentsOfView.append(ParentOfView(name: detail.name))
                }
                switch type {
                case .textInput:
                    let newView = InputFieldView()
                    newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                height: type.height)
                    var type: InputValidator = .intNamed(detail.label.translationText)
                    switch detail.constraints?.inputType {
                    case "numeric":
                        type = .intNamed(detail.label.translationText)
                    case "text":
                        type = .stringNamed(detail.label.translationText)
                    default: break
                    }
                    newView.set(type: type,
                                canBeEmpty: true,
                                hideError: true,
                                placeholder: detail.placeholder,
                                shouldBeUpper: true,
                                returnKey: .next,
                                textSize: 15)
                    newView.value = NewOffer.Values(key: detail.name, value: "")
                    newView.endEditing = { [unowned self] in
                        if vm.details.contains(where: { $0.key == newView.value.key }) {
                            let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                            vm.details[index!] = newView.value
                        } else {
                            vm.details.append(newView.value)
                        }
                    }
                    categoryDetailsStack.addArrangedSubview(newView)
                    
                case .radioBox:
                    let newView = TwoRadioButtonsView()
                    newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                height: type.height)
                    let firstOption = detail.options.first?.label.translationText ?? ""
                    let secondOption = detail.options.last?.label.translationText ?? ""
                    newView.setup(sectionLabel: detail.label.translationText,
                                  optionOne: firstOption,
                                  optionTwo: secondOption,
                                  isFirstSelected: true)
                    newView.value = NewOffer.Values(key: detail.name, value: firstOption)
                    if vm.details.contains(where: { $0.key == newView.value.key }) {
                        let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                        vm.details[index!] = newView.value
                    } else {
                        vm.details.append(newView.value)
                    }
                    newView.reloadData = { [unowned self] in
                        if vm.details.contains(where: { $0.key == newView.value.key }) {
                            let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                            vm.details[index!] = newView.value
                        } else {
                            vm.details.append(newView.value)
                        }
                    }
                    categoryDetailsStack.addArrangedSubview(newView)
                    
                case .dropDown:
                    let newView = DropDownView()
                    newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                height: type.height)
                    if detail.parent == "" {
                        var dataSource: [String] = []
                        for option in detail.options {
                            if option.name.isEmpty {
                                if let label = option.label.first(where: { $0.language == L10n.shared.language }) {
                                    dataSource.append(label.translation)
                                }
                            } else {
                                dataSource.append(option.name)
                            }
                        }
                        //let dataSource = detail.options.map { $0.name }
                        let parent = vm.parentsOfView.first {  $0.name == detail.name }
                        let index = dataSource.firstIndex(of: parent?.selectedValue ?? "")
                        newView.setDataSource(dataSource: dataSource,
                                              selectedIndex: index,
                                              title: detail.label.translationText, placeholder: detail.placeholder ?? "")
                        newView.doneEditing = { [unowned self] in
                            vm.parentsOfView.first {  $0.name == detail.name }?.selectedValue = newView.selectedText ?? ""
                            //createTotalCategoryDetails()
                            if vm.details.contains(where: { $0.key == newView.value.key }) {
                                let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                                vm.details[index!] = newView.value
                            } else {
                                vm.details.append(newView.value)
                            }
                        }
                        newView.value = NewOffer.Values(key: detail.name, value: "")
                        categoryDetailsStack.addArrangedSubview(newView)
                    } else {
                        let newView = DropDownView()
                        newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                    height: type.height)
                        let selectedValue = vm.parentsOfView.first {  $0.name == detail.parent}?.selectedValue
                        newView.isHidden = selectedValue == ""
                        var dataSource: [String] = []
                        for option in detail.options {
                            if option.parentOption  == selectedValue {
                                dataSource = option.childOptions ?? []
                            }
                        }
                        newView.setDataSource(dataSource: dataSource, title: detail.label.translationText, placeholder: detail.placeholder ?? "")
                        newView.value = NewOffer.Values(key: detail.name, value: "")
                        newView.doneEditing = { [unowned self] in
                            if vm.details.contains(where: { $0.key == newView.value.key }) {
                                let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                                vm.details[index!] = newView.value
                            } else {
                                vm.details.append(newView.value)
                            }
                        }
                        categoryDetailsStack.addArrangedSubview(newView)
                    }
                    
                }
            }
        }
    }
    
    func getSubcategoryItems() -> [CategoryDetails] {
        var listOFSub: [CategoryDetails] = []
        if let category = vm.category {
            print(selectedSubcategory)
            for subcategoryItem in category.subcategories {
                if subcategoryItem.name.lowercased() == selectedSubcategory.lowercased() {
                    listOFSub.append(subcategoryItem)
                }
            }
        }
        return listOFSub
    }
    
    private func createCategoryDetails() {
        if let category = vm.category {
            let orderedDetails = category.categoryDetails.sorted { $0.guiOrder < $1.guiOrder }
            for detail in orderedDetails {
                guard let type = AddOfferElement(rawValue: detail.type) else { continue }
                if detail.parent == "" {
                    vm.parentsOfView.append(ParentOfView(name: detail.name))
                }
                switch type {
                case .textInput:
                    let newView = InputFieldView()
                    newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                height: type.height)
                    var type: InputValidator = .stringNamed(detail.label.translationText)
                    switch detail.constraints?.inputType {
                    case "numeric" :
                        type = .intNamed(detail.label.translationText)
                    case "text":
                        type = .stringNamed(detail.label.translationText)
                    default: break
                    }
                    newView.set(type: type,
                                canBeEmpty: true,
                                hideError: true,
                                placeholder: detail.placeholder,
                                shouldBeUpper: true,
                                returnKey: .next,
                                textSize: 15)
                    newView.value = NewOffer.Values(key: detail.name, value: "")
                    newView.endEditing = { [unowned self] in
                        if vm.details.contains(where: { $0.key == newView.value.key }) {
                            let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                            vm.details[index!] = newView.value
                        } else {
                            vm.details.append(newView.value)
                        }
                    }
                    categoryDetailsStack.addArrangedSubview(newView)
                    
                case .radioBox:
                    let newView = TwoRadioButtonsView()
                    newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                height: type.height)
                    let firstOption = detail.options.first?.label.translationText ?? ""
                    let secondOption = detail.options.last?.label.translationText ?? ""
                    newView.setup(sectionLabel: detail.label.translationText,
                                  optionOne: firstOption,
                                  optionTwo: secondOption,
                                  isFirstSelected: true)
                    newView.value = NewOffer.Values(key: detail.name, value: firstOption)
                    if vm.details.contains(where: { $0.key == newView.value.key }) {
                        let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                        vm.details[index!] = newView.value
                    } else {
                        vm.details.append(newView.value)
                    }
                    newView.reloadData = { [unowned self] in
                        if vm.details.contains(where: { $0.key == newView.value.key }) {
                            let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                            vm.details[index!] = newView.value
                        } else {
                            vm.details.append(newView.value)
                        }
                    }
                    categoryDetailsStack.addArrangedSubview(newView)
                    
                case .dropDown:
                    let newView = DropDownView()
                    newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                height: type.height)
                    if detail.parent == "" {
                        var dataSource: [String] = []
                        for option in detail.options {
                            if option.name.isEmpty {
                                if let label = option.label.first(where: { $0.language == L10n.shared.language }) {
                                    dataSource.append(label.translation)
                                }
                            } else {
                                dataSource.append(option.name)
                            }
                        }
                       // let dataSource = detail.options.map { $0.name }
                        let parent = vm.parentsOfView.first {  $0.name == detail.name }
                        let index = dataSource.firstIndex(of: parent?.selectedValue ?? "")
                        newView.setDataSource(dataSource: dataSource,
                                              selectedIndex: index,
                                              title: detail.label.translationText, placeholder: detail.placeholder ?? "")
                        newView.doneEditing = { [unowned self] in
                            vm.parentsOfView.first {  $0.name == detail.name }?.selectedValue = newView.selectedText ?? ""
                            //createTotalCategoryDetails()
                            if vm.details.contains(where: { $0.key == newView.value.key }) {
                                let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                                vm.details[index!] = newView.value
                            } else {
                                vm.details.append(newView.value)
                            }
                        }
                        newView.value = NewOffer.Values(key: detail.name, value: "")
                        categoryDetailsStack.addArrangedSubview(newView)
                    } else {
                        let newView = DropDownView()
                        newView.frame.size = CGSize(width: categoryDetailsStack.frame.width,
                                                    height: type.height)
                        let selectedValue = vm.parentsOfView.first {  $0.name == detail.parent}?.selectedValue
                        newView.isHidden = selectedValue == ""
                        var dataSource: [String] = []
                        for option in detail.options {
                            if option.parentOption  == selectedValue {
                                dataSource = option.childOptions ?? []
                            }
                        }
                        newView.setDataSource(dataSource: dataSource, title: detail.label.translationText, placeholder: detail.placeholder ?? "")
                        newView.value = NewOffer.Values(key: detail.name, value: "")
                        newView.doneEditing = { [unowned self] in
                            if vm.details.contains(where: { $0.key == newView.value.key }) {
                                let index = vm.details.firstIndex(where: { $0.key == newView.value.key })
                                vm.details[index!] = newView.value
                            } else {
                                vm.details.append(newView.value)
                            }
                        }
                        categoryDetailsStack.addArrangedSubview(newView)
                    }
                }
            }
        }
    }
    
    func setInputs() {
        let currencyTypes = ["lei".l10n(),
                             "euro".l10n()]
        
        if let search = Offline.decode(key: .currentSearch, type: SearchWithFilter.self) {
            var startPrice = ""
            if let price = search.priceFilter?.lowestPrice, price != 0.0 {
                startPrice = "\(Int(price))"
                vm.startPrice = price
            }
            startPriceInput.setupInputField(title: "startPrice".l10n(),
                                            type: .intNamed(""),
                                            inputText: startPrice,
                                            placeholder: "addOffer_price_placeholder".l10n(), canBeEmpty: true)
            let currentCurrency = search.priceFilter!.currencyType == CurrencyType.ron.type ? "lei".l10n() : "euro".l10n()
            let indexOfCurrency = currencyTypes.firstIndex(of: currentCurrency) ?? 0
            startPriceInput.setupDropdown(dataSource: currencyTypes,selectedIndex: indexOfCurrency)
            startPriceInput.actionAfterSet = { [unowned self] in
                endPriceInput.setupDropdown(dataSource: currencyTypes, selectedIndex: currencyTypes.firstIndex(of: startPriceInput.selectedDropdownOption) ?? 0)
                vm.currency =  startPriceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
            }
            var endPrice = ""
            if let price = search.priceFilter?.highestPrice, price != 0.0 {
                endPrice = "\(Int(price))"
                vm.endPrice = price
            }
            
            endPriceInput.setupInputField(title: "endPrice".l10n(),
                                          type: .intNamed(""),
                                          inputText: endPrice,
                                          placeholder: "addOffer_price_placeholder".l10n(), canBeEmpty: true)
            endPriceInput.setupDropdown(dataSource: currencyTypes, selectedIndex: indexOfCurrency)
            endPriceInput.actionAfterSet = { [unowned self] in
                startPriceInput.setupDropdown(dataSource: currencyTypes, selectedIndex: currencyTypes.firstIndex(of: endPriceInput.selectedDropdownOption) ?? 0)
                vm.currency =  endPriceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
            }
            vm.currency = startPriceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
            
            typeRadioButton.setup(sectionLabel: "addOffer_offer_type".l10n(),
                                  optionOne: "addOffer_fixPrice".l10n(),
                                  optionTwo: "addOffer_auction".l10n(),
                                  isFirstSelected: search.offerType == OfferType.fixPrice.type,
                                  canBeBoth: true,
                                  isSecondSelected: search.offerType == OfferType.auction.type)
            if let offerType = search.offerType {
                vm.offerType = offerType == OfferType.fixPrice.type ? .fixPrice : .auction
            }
            typeRadioButton.reloadData = { [unowned self] in
                if typeRadioButton.isFirstSelected && typeRadioButton.isSecondSelected {
                    vm.offerType = nil
                } else if typeRadioButton.isFirstSelected {
                    vm.offerType = OfferType.fixPrice
                } else if typeRadioButton.isSecondSelected {
                    vm.offerType = OfferType.auction
                } else {
                    vm.offerType = nil
                }
            }
            let indexOfCountries = Offline.counties.firstIndex(of: search.location ?? "")
            
            locationDropDown.setDataSource(dataSource: Offline.counties, selectedIndex: indexOfCountries, title: "addOffer_location".l10n(), placeholder: "addOffer_country".l10n())
            vm.location = search.location
            locationDropDown.doneEditing = { [unowned self] in
                vm.location = locationDropDown.selectedText ?? ""
            }
            
            conditionRadioButton.setup(sectionLabel: "addOffer_condition".l10n(),
                                       optionOne: "addOffer_new".l10n(),
                                       optionTwo: "addOffer_used".l10n(),
                                       isFirstSelected: search.conditionType == ConditionType.new.type,
                                       canBeBoth: true,
                                       isSecondSelected: search.conditionType == ConditionType.used.type)
            if let conditionType = search.conditionType {
                vm.condition = conditionType == ConditionType.new.type ? .new : .used
            }
            conditionRadioButton.reloadData = { [unowned self] in
                if conditionRadioButton.isFirstSelected && conditionRadioButton.isSecondSelected {
                    vm.condition = nil
                } else if conditionRadioButton.isFirstSelected {
                    vm.condition = ConditionType.new
                } else if conditionRadioButton.isSecondSelected {
                    vm.condition = ConditionType.used
                } else {
                    vm.condition = nil
                }
            }
        } else {
            startPriceInput.setupInputField(title: "Start price",
                                            type: .intNamed(""),
                                            inputText: "",
                                            placeholder: "addOffer_price_placeholder".l10n(), canBeEmpty: true)
            startPriceInput.setupDropdown(dataSource: currencyTypes)
            startPriceInput.actionAfterSet = { [unowned self] in
                endPriceInput.setupDropdown(dataSource: currencyTypes, selectedIndex: currencyTypes.firstIndex(of: startPriceInput.selectedDropdownOption) ?? 0)
                vm.currency =  startPriceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
            }
            
            endPriceInput.setupInputField(title: "End price",
                                          type: .intNamed(""),
                                          inputText: "",
                                          placeholder: "addOffer_price_placeholder".l10n(), canBeEmpty: true)
            endPriceInput.setupDropdown(dataSource: currencyTypes)
            endPriceInput.actionAfterSet = { [unowned self] in
                startPriceInput.setupDropdown(dataSource: currencyTypes, selectedIndex: currencyTypes.firstIndex(of: endPriceInput.selectedDropdownOption) ?? 0)
                vm.currency =  endPriceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
            }
            vm.currency = startPriceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
            typeRadioButton.setup(sectionLabel: "addOffer_offer_type".l10n(),
                                  optionOne: "addOffer_fixPrice".l10n(),
                                  optionTwo: "addOffer_auction".l10n(),
                                  isFirstSelected: false,
                                  canBeBoth: true,
                                  isSecondSelected: false)
            typeRadioButton.reloadData = { [unowned self] in
                if typeRadioButton.isFirstSelected && typeRadioButton.isSecondSelected {
                    vm.offerType = nil
                } else if typeRadioButton.isFirstSelected {
                    vm.offerType = OfferType.fixPrice
                } else if typeRadioButton.isSecondSelected {
                    vm.offerType = OfferType.auction
                } else {
                    vm.offerType = nil
                }
            }
            
            locationDropDown.setDataSource(dataSource: Offline.counties, title: "addOffer_location".l10n(), placeholder: "addOffer_country".l10n())
            locationDropDown.doneEditing = { [unowned self] in
                vm.location = locationDropDown.selectedText ?? ""
            }
            
            conditionRadioButton.setup(sectionLabel: "addOffer_condition".l10n(),
                                       optionOne: "addOffer_new".l10n(),
                                       optionTwo: "addOffer_used".l10n(),
                                       isFirstSelected: false,
                                       canBeBoth: true,
                                       isSecondSelected: false)
            conditionRadioButton.reloadData = { [unowned self] in
                if conditionRadioButton.isFirstSelected && conditionRadioButton.isSecondSelected {
                    vm.condition = nil
                } else if conditionRadioButton.isFirstSelected {
                    vm.condition = ConditionType.new
                } else if conditionRadioButton.isSecondSelected {
                    vm.condition = ConditionType.used
                } else {
                    vm.condition = nil
                }
            }
        }
        
        addFilter.action = { [unowned self] in
            var details: [DetailsFilter] = []
            for detail in vm.details {
                details.append(DetailsFilter(key: detail.key, value: detail.value))
            }
            var categories: [Int] = []
            if let cat = vm.category {
                categories.append(cat.id)
            }
            let search = SearchWithFilter(condition: vm.condition?.type, priceFilter: PriceFilter(highestPrice: vm.endPrice, lowestPrice: vm.startPrice, currencyType: vm.currency.type), location: vm.location, categories: categories, offerType: vm.offerType?.type, title: vm.text)
            Offline.encode(search, key: .currentSearch)
            vm.searchWithFilter(filter: search)
        }
    }
}

extension FilterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        vm.subcategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubcategoryCVCell.identifier, for: indexPath) as! SubcategoryCVCell
        
        cell.setupView(title: vm.subcategories[indexPath.item], image: vm.category!.subcategories[indexPath.row].icon)
        let index = vm.subcategoriesNames.firstIndex(of: selectedSubcategory) ?? 0
        vm.selectedSubcategoryId = vm.subcategoriesIds[index]
        if vm.subcategories[indexPath.item] == vm.subcategories[index] {
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedSubcategory = vm.subcategoriesNames[indexPath.item]
        vm.selectedSubcategoryId = vm.subcategoriesIds[indexPath.item]
        createTotalCategoryDetails()
        return
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 181, height: 92)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}
