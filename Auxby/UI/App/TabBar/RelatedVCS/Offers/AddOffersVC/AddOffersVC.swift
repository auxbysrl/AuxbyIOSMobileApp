//
//  AddOffersVC.swift
//  Auxby
//
//  Created by Andrei Traciu on 10.01.2023.
//

import UIKit
import PhotosUI
import L10n_swift

enum AddOfferElement: String {
    case textInput = "text_input"
    case radioBox = "radio_box"
    case dropDown = "drop_down"
    
    var height: CGFloat {
        switch self {
        case .textInput:    return 80
        case .radioBox:     return 53
        case .dropDown:     return 96
        }
    }
}

class AddOffersVC: UIViewController{
    
    // MARK: IBOutlets
    @IBOutlet weak var offerCategoryImgView: UIImageView!
    @IBOutlet weak var offerCategoryLbl: UILabel!
    
    @IBOutlet weak var subcategoryView: UIView!
    @IBOutlet weak var subcategoryCollectionView: UICollectionView!
    
    @IBOutlet weak var titleInput: InputFieldView!
    @IBOutlet weak var offerTypeInput: TwoRadioButtonsView!
    @IBOutlet weak var priceInput: DropDownWithTextInput!
    
    @IBOutlet weak var conditionInput: TwoRadioButtonsView!
    @IBOutlet weak var descriptionInput: TextViewInput!
    @IBOutlet weak var stopDateInput: InputFieldView!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var phoneInput: InputFieldView!
    @IBOutlet weak var locationDropDown: DropDownView!
    @IBOutlet var continueBtn: MainButtonView!
    
    @IBOutlet weak var categoryDetailsStack: UIStackView!
    @IBOutlet weak var categoryDetailsParentStack: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var autoExtendLabel: UILabel!
    @IBOutlet weak var autoExtendSwitch: UISwitch!
    @IBOutlet weak var autoExtendView: UIView!
    @IBOutlet weak var imageForPhotos: UIImageView!
    
    
    
    // MARK: Public Properties
    var vm = AddOfferVM()
    var indicator: ActivityIndicator?
    
    // MARK: Private Properties
    private var selectedSubcategory: String = ""
    private var maxPhotos: Int = 6
    fileprivate var identifiers: [String] = []
    
    // MARK: Overriden Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if let offer = vm.offer {
            setupEditView(offer)
        } else {
            setupView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = Offline.currentUser {
            subcategoryCollectionView.reloadData()
            if let offer = vm.offer {
                if let photos = offer.photos {
                    for photo in photos {
                        if ImageDownloader.isDownloaded(imageUrl: photo.url!) {
                            ImageDownloader.get(photo.url!) { [unowned self] imageObj in
                                vm.photos.append(imageObj.image)
                                if vm.photos.count == photos.count {
                                    photosCollectionView.reloadData()
                                }
                            }
                        }
                        
                    }
                }
            }
        } else {
            if vm.offer != nil {
                popVC()
            } else {
                popVC(2)
            }
        }
    }
    
    // MARK: IBActions
    @IBAction func removeCategoryAction(_ sender: Any) {
        if let _ = vm.offer {
        } else {
            popVC()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func autoExtend(_ sender: UISwitch) {
        autoExtendLabel.text = sender.isOn ? "autoExtendOffer".l10n() : "offerExpire".l10n()
    }
    
    // MARK: Private Methods
    private func setupView() {
        scrollView.setBottomConstraintToTopOfKeyboard()
        setObservable()
        hideKeyboardWhenTappedAround()
        subcategoryCollectionView.delegate = self
        subcategoryCollectionView.dataSource = self
        subcategoryCollectionView.allowsMultipleSelection = false
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        
        subcategoryView.isHidden = vm.subcategories.isEmpty
        if !vm.subcategories.isEmpty {
            selectedSubcategory = vm.subcategoriesNames.first ?? ""
        }
        subcategoryCollectionView.reloadData()
        
        offerCategoryLbl.text = vm.category.label.translationText
        if vm.category.icon.first == "." {
            vm.category.icon.remove(at: vm.category.icon.startIndex)
        }
        offerCategoryImgView.setImage(from: vm.category.icon)
        setupInputField()
        
        categoryDetailsStack.isHidden = vm.category.categoryDetails.isEmpty
        createTotalCategoryDetails()
    }
    
    private func setupInputField() {
        titleInput.set(type: .sentanceNamed("addOffer_title".l10n()),
                       canBeEmpty: false,
                       placeholder: "addOffer_title_placeholder".l10n(),
                       shouldBeUpper: true,
                       returnKey: .done,
                       textSize: 15)
        
        offerTypeInput.setup(sectionLabel: "addOffer_offer_type".l10n(),
                             optionOne: "addOffer_fixPrice".l10n(),
                             optionTwo: "addOffer_auction".l10n(),
                             isFirstSelected: true)
        offerTypeInput.reloadData = { [unowned self] in
            stopDateInput.isHidden = offerTypeInput.isFirstSelected
            vm.isBidType = !offerTypeInput.isFirstSelected
            vm.offerType = vm.isBidType ? .auction : .fixPrice
        }
        stopDateInput.shouldUseDatePicker = true
        stopDateInput.set(type: .notEmpty,
                          canBeEmpty: false,
                          hideError: false,
                          placeholder: "04 april 1998",
                          shouldBeUpper: true,
                          returnKey: .done,
                          textSize: 15)
        stopDateInput.title = "addOffer_end_data".l10n()
        stopDateInput.endEditing = { [unowned self] in
            vm.stopDate = stopDateInput.text
            setNextButton()
        }
        
        priceInput.setupInputField(title: "addOffer_price".l10n(),
                                   type: .intNamed(""),
                                   inputText: "",
                                   placeholder: "addOffer_price_placeholder".l10n())
        priceInput.setupDropdown(dataSource: ["lei".l10n(),
                                              "euro".l10n()])
        priceInput.actionAfterSet = { [unowned self] in
            vm.currency = priceInput.selectedDropdownOption == "lei".l10n() ? .ron : .euro
        }
        
        conditionInput.setup(sectionLabel: "addOffer_condition".l10n(),
                             optionOne: "addOffer_new".l10n(),
                             optionTwo: "addOffer_used".l10n(),
                             isFirstSelected: true)
        conditionInput.reloadData = { [unowned self] in
            vm.condition = conditionInput.isFirstSelected ? .new : .used
        }
        
        descriptionInput.setup(type: .sentanceNamed("addOffer_description".l10n()),
                               canBeEmpty: false,
                               hideError: false,
                               returnKey: .default)
        if let index = Offline.counties.firstIndex(of: Offline.currentUser?.address.city ?? "") {
            locationDropDown.setDataSource(dataSource: Offline.counties, selectedIndex: index, title: "addOffer_location".l10n(), placeholder: "addOffer_country".l10n())
            vm.location = locationDropDown.selectedText!
        } else {
            locationDropDown.setDataSource(dataSource: Offline.counties, title: "addOffer_location".l10n(), placeholder: "addOffer_country".l10n())
        }
        
        locationDropDown.doneEditing = { [unowned self] in
            vm.location = locationDropDown.selectedText!
            setNextButton()
        }
        
        phoneInput.set(type: .phoneNumber,
                       text: Offline.currentUser?.phone ?? "",
                       canBeEmpty: false,
                       hideError: false,
                       placeholder: "addOffer_phone_placeholder".l10n(),
                       shouldBeUpper: true,
                       returnKey: .done, keyboardNextAction: {
            self.view.endEditing(true)
        }, textSize: 15)
        vm.phone = Offline.currentUser?.phone ?? ""
        
        
        continueBtn.set(title: "continue".l10n()) { [unowned self] in
            let newOffer = NewOffer()
            if let subcatID = vm.selectedSubcategoryId {
                newOffer.categoryId = subcatID
            } else {
                newOffer.categoryId = vm.category.id
            }
            newOffer.title = vm.title
            newOffer.description = vm.description
            newOffer.price = Double(vm.price) ?? 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.date(from: vm.stopDate)
            newOffer.auctionEndDate = vm.isBidType ? date!.toString(format: "yyyy-MM-dd") : ""
            let calendar = Calendar.current
            if let date = date {
                if let difference = calendar.dateComponents([.day], from: Date() + 1, to: date).day {
                    newOffer.requiredCoins = difference >= 60 ?  3 * vm.category.addOfferCost : difference >= 30 ? 2 * vm.category.addOfferCost : vm.category.addOfferCost
                } else {
                    newOffer.requiredCoins = vm.category.addOfferCost
                }
            } else {
                newOffer.requiredCoins = vm.category.addOfferCost
            }
            newOffer.offerType = vm.offerType.type
            newOffer.currencyType = vm.currency.type
            newOffer.conditionType = vm.condition.type
            newOffer.contactInfo = NewOffer.ContactInfo(location: vm.location, phoneNumber: vm.phone)
            newOffer.categoryDetails = vm.details
            newOffer.autoExtend = autoExtendSwitch.isOn
            
            let previewVC = PreviewOrDetailsVC.asVC() as! PreviewOrDetailsVC
            previewVC.vm = PreviewOrDetailsVM(newOffer: newOffer)
            previewVC.vm.photos = vm.photos
            pushVC(previewVC)
        }
    }
    
    func setObservable() {
        titleInput.textPublisher.sink { [unowned self] text in
            if text!.count <= 80 {
                vm.title = text!
            }
            setNextButton()
        }.store(in: &vm.cancellables)
        
        priceInput.textPublisher.sink { [unowned self] text in
            vm.price = text!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        descriptionInput.textPublisher.sink { [unowned self] text in
            vm.description = text!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        stopDateInput.textPublisher.sink { [unowned self] text in
            setNextButton()
        }.store(in: &vm.cancellables)
        
        phoneInput.textPublisher.sink { [unowned self] text in
            vm.phone = text!
            setNextButton()
        }.store(in: &vm.cancellables)
        
        vm.$editOfferState.sink { [unowned self] state in
            switch state {
            case .succeed:
                NotifyCenter.post(.updateOffers)
                if !vm.photos.isEmpty {
                    vm.addImagesForOffer(images: vm.photos, id: vm.offer!.id)
                } else {
                    indicator = nil
                    popVC()
                }
            case .failed(let err):
                UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
    }
    
    fileprivate func presentImagePicker(imageViewBase: UIView) {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = maxPhotos - vm.photos.count
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    fileprivate func presentPhotoAction(indexToEdit: Int) {
        let option1 = UIAlert.Option(title: "addOffer_make_it_cover".l10n(), action: {
            self.updatePhotos(index: indexToEdit, shouldBeRemoved: false)
        })
        
        let option2 = UIAlert.Option(title: "delete".l10n(), action: {
            self.updatePhotos(index: indexToEdit, shouldBeRemoved: true)
        })
        
        UIAlert.showActionSheet(vc: self,
                                options: [option1, option2],
                                iPadSourceView: UIView())
    }
    
    private func updatePhotos(index: Int, shouldBeRemoved: Bool) {
        if shouldBeRemoved {
            vm.photos.remove(at: index)
            photosCollectionView.reloadData()
            return
        }
        let currentPhoto = vm.photos[index]
        vm.photos.remove(at: index)
        vm.photos.insert(currentPhoto, at: 0)
        photosCollectionView.reloadData()
    }
    
    private func createTotalCategoryDetails() {
        categoryDetailsParentStack.removeAllSubviews()
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
                    newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                    categoryDetailsParentStack.addArrangedSubview(newView)
                    
                case .radioBox:
                    let newView = TwoRadioButtonsView()
                    newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                    categoryDetailsParentStack.addArrangedSubview(newView)
                    
                case .dropDown:
                    let newView = DropDownView()
                    newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                        categoryDetailsParentStack.addArrangedSubview(newView)
                    } else {
                        let newView = DropDownView()
                        newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                        categoryDetailsParentStack.addArrangedSubview(newView)
                    }
                    
                }
            }
        }
    }
    
    func getSubcategoryItems() -> [CategoryDetails] {
        var listOFSub: [CategoryDetails] = []
        print(selectedSubcategory)
        for subcategoryItem in vm.category.subcategories {
            if subcategoryItem.name.lowercased() == selectedSubcategory.lowercased() {
                listOFSub.append(subcategoryItem)
            }
        }
        return listOFSub
    }
    
    func getSubcategoryItemsEdit(_ offer: OfferDetails) -> [CategoryDetails] {
        var listOFSub: [CategoryDetails] = []
        print(selectedSubcategory)
        for subcategoryItem in vm.category.subcategories {
            if subcategoryItem.id == offer.categoryId {
                listOFSub.append(subcategoryItem)
            }
        }
        return listOFSub
    }
    
    
    
    private func createCategoryDetails() {
        let orderedDetails = vm.category.categoryDetails.sorted { $0.guiOrder < $1.guiOrder }
        for detail in orderedDetails {
            guard let type = AddOfferElement(rawValue: detail.type) else { continue }
            if detail.parent == "" {
                vm.parentsOfView.append(ParentOfView(name: detail.name))
            }
            switch type {
            case .textInput:
                let newView = InputFieldView()
                newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                categoryDetailsParentStack.addArrangedSubview(newView)
                
            case .radioBox:
                let newView = TwoRadioButtonsView()
                newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                categoryDetailsParentStack.addArrangedSubview(newView)
                
            case .dropDown:
                let newView = DropDownView()
                newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                    categoryDetailsParentStack.addArrangedSubview(newView)
                } else {
                    let newView = DropDownView()
                    newView.frame.size = CGSize(width: categoryDetailsParentStack.frame.width,
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
                    categoryDetailsParentStack.addArrangedSubview(newView)
                }
            }
        }
    }
    
    private func addThirtyDays() -> Date {
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: 30, to: currentDate)!
    }
    
    private func getOfferDetails() -> [NewOffer.Values] {
        var details: [NewOffer.Values] = []
        for subview in categoryDetailsParentStack.arrangedSubviews {
            if let currentView = subview as? NewOfferValue {
                details.append(currentView.value)
            }
        }
        
        return details
    }
    
    func setNextButton() {
        let allInputs = [titleInput, priceInput, descriptionInput, phoneInput].compactMap{$0 as? InputValidationProtocol}
        if vm.isBidType {
            continueBtn.isActive = allInputs.areValid && stopDateInput.isValid && !vm.location.isEmpty
        } else {
            continueBtn.isActive = allInputs.areValid && !vm.location.isEmpty
        }
    }
}

extension AddOffersVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == subcategoryCollectionView {
            return vm.subcategories.count
        }
        if vm.photos.count < maxPhotos {
            return vm.photos.count + 1
        } else {
            return vm.photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == subcategoryCollectionView {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SubcategoryCVCell.identifier, for: indexPath) as? SubcategoryCVCell {
                
                cell.setupView(title: vm.subcategories[indexPath.item], image: vm.category.subcategories[indexPath.row].icon)
                let index = vm.subcategoriesNames.firstIndex(of: selectedSubcategory) ?? 0
                vm.selectedSubcategoryId = vm.subcategoriesIds[index]
                if vm.subcategories[indexPath.item] == vm.subcategories[index] {
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                }
                return cell
            }
        }
        
        if let photosCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCVCell.identifier, for: indexPath) as? PhotoCVCell {
            if vm.photos.count < maxPhotos {
                if indexPath.item == 0 {
                    photosCell.setState(photoState: .addPhoto, imageToUse: nil)
                } else {
                    photosCell.setState(photoState: indexPath.item == 1 ? .cover : .simple,
                                        imageToUse: vm.photos[indexPath.item - 1])
                }
            } else {
                photosCell.setState(photoState: indexPath.item == 0 ?  .cover : .simple,
                                    imageToUse: vm.photos[indexPath.item])
            }
            return photosCell
        }
        
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == subcategoryCollectionView {
            selectedSubcategory = vm.subcategoriesNames[indexPath.item]
            vm.selectedSubcategoryId = vm.subcategoriesIds[indexPath.item]
            createTotalCategoryDetails()
            return
        }
        
        if indexPath.item == 0 {
            if vm.photos.count < maxPhotos {
                presentImagePicker(imageViewBase: UIView())
            }
        } else {
            presentPhotoAction(indexToEdit: indexPath.item-1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == subcategoryCollectionView {
            return CGSize(width: 181, height: 92)
        }
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
}

extension AddOffersVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    // Handle the selected image here
                    if let image = image as? UIImage {
                        self.vm.photos.append(image)
                        let identifier = result.assetIdentifier ?? ""
                        self.identifiers.append(identifier)
                        runOnMainThread {
                            self.photosCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func pickerDidCancel(_ picker: PHPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
