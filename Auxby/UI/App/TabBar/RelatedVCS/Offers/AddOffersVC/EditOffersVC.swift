//
//  EditOfferVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 24.05.2023.
//

import Foundation
import L10n_swift

extension AddOffersVC {
     func setupEditView(_ offer: OfferDetails) {
        scrollView.setBottomConstraintToTopOfKeyboard()
        setObservable()
        hideKeyboardWhenTappedAround()
        subcategoryCollectionView.delegate = self
        subcategoryCollectionView.dataSource = self
        subcategoryCollectionView.allowsMultipleSelection = false
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
         if let details = offer.details {
             for detail in details {
                 vm.details.append(detail.toValue())
             }
         }
        subcategoryView.isHidden = true
        offerCategoryLbl.text = vm.category.label.translationText
         if vm.category.icon.first == "." {
             vm.category.icon.remove(at: vm.category.icon.startIndex)
         }
        offerCategoryImgView.setImage(from: vm.category.icon)
        setupInputFieldOffer(offer)
        
        categoryDetailsStack.isHidden = vm.category.categoryDetails.isEmpty
        createTotalCategoryDetailsOffer(offer)
        
        autoExtendSwitch.isOn = offer.autoExtend
        autoExtendLabel.text = autoExtendSwitch.isOn ? "autoExtendOffer".l10n() : "offerExpire".l10n()
    }
    
     func setupInputFieldOffer(_ offer: OfferDetails) {
        titleInput.set(type: .sentanceNamed("addOffer_title".l10n()),
                       text: offer.title,
                       canBeEmpty: false,
                       placeholder: "addOffer_title_placeholder".l10n(),
                       shouldBeUpper: true,
                       returnKey: .done,
                       textSize: 15)
        vm.title = offer.title
        offerTypeInput.setup(sectionLabel: "addOffer_offer_type".l10n(),
                             optionOne: "addOffer_fixPrice".l10n(),
                             optionTwo: "addOffer_auction".l10n(),
                             isFirstSelected: !offer.isOnAuction)
        offerTypeInput.isUserInteractionEnabled = false
        priceInput.setupInputField(title: "addOffer_price".l10n(),
                                   type: .intNamed(""),
                                   inputText: "\(Int(offer.price))",
                                   placeholder: "addOffer_price_placeholder".l10n())
         var symbols: [String] = []
         if let currencies = Offline.decode(key: .currencies, type: [Currency].self) {
             for currency in currencies {
                 symbols.append(currency.symbol)
             }
         }
        priceInput.setupDropdown(dataSource: symbols, selectedIndex: symbols.firstIndex(of: offer.currencySymbol ?? "") ?? 0)
        priceInput.actionAfterSet = { [unowned self] in
            if let currencies = Offline.decode(key: .currencies, type: [Currency].self) {
                if let currentCurrency = currencies.first(where: { $0.symbol == priceInput.selectedDropdownOption }) {
                    vm.currency = currentCurrency.name
                }
            }
        }
        vm.price = "\(offer.price)"
        vm.currency = offer.currencyType ?? ""
        
        conditionInput.setup(sectionLabel: "addOffer_condition".l10n(),
                             optionOne: "addOffer_new".l10n(),
                             optionTwo: "addOffer_used".l10n(),
                             isFirstSelected: offer.condition == ConditionType.new.type.uppercased())
        conditionInput.reloadData = { [unowned self] in
            vm.condition = conditionInput.isFirstSelected ? .new : .used
        }
        vm.condition = conditionInput.isFirstSelected ? .new : .used
        
        descriptionInput.setup(type: .sentanceNamed("addOffer_description".l10n()),
                               text: offer.description,
                               canBeEmpty: false,
                               hideError: false,
                               returnKey: .done)
        vm.description = offer.description

         let locationIndex = Offline.counties.firstIndex(of: offer.location) ?? 0
         locationDropDown.setDataSource(dataSource: Offline.counties, selectedIndex: locationIndex, title: "addOffer_location".l10n(), placeholder: "addOffer_country".l10n())
         
         locationDropDown.doneEditing = { [unowned self] in
             vm.location = locationDropDown.selectedText!
             setNextButton()
         }
        vm.location = offer.location
        
        phoneInput.set(type: .phoneNumber,
                       text: offer.phoneNumbers,
                       canBeEmpty: false,
                       hideError: false,
                       placeholder: "addOffer_phone_placeholder".l10n(),
                       shouldBeUpper: true,
                       returnKey: .done, keyboardNextAction: {
            self.view.endEditing(true)
        }, textSize: 15)
        vm.phone = offer.phoneNumbers ?? ""
        
        
        continueBtn.set(title: "save".l10n()) { [unowned self] in
            let newOffer = NewOffer()
            newOffer.categoryId = offer.categoryId
            newOffer.title = vm.title
            newOffer.description = vm.description
            newOffer.requiredCoins = 0
            newOffer.price = Double(vm.price) ?? 0
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            let date = dateFormatter.date(from: vm.stopDate)
            newOffer.auctionEndDate = vm.isBidType ? date!.toString(format: "yyyy-MM-dd") : ""
            newOffer.offerType = vm.offerType.type
            newOffer.currencyType = vm.currency
            newOffer.conditionType = vm.condition.type
            newOffer.contactInfo = NewOffer.ContactInfo(location: vm.location, phoneNumber: vm.phone)
            newOffer.categoryDetails = vm.details
            newOffer.autoExtend = autoExtendSwitch.isOn
            //call to send edited offer
            vm.editOffer(newOffer)
            indicator = ActivityIndicator()
            vm.imagesAdded = {
                self.indicator = nil
            }
        }
         setNextButton()
    }
    
     func createTotalCategoryDetailsOffer(_ offer: OfferDetails) {
        categoryDetailsParentStack.removeAllSubviews()
        createSubCategoryDetailsOffer(offer)
        createCategoryDetailsOffer(offer)
    }
    
     func createSubCategoryDetailsOffer(_ offer: OfferDetails) {
        let subcategoryList = getSubcategoryItemsEdit(offer)
        if subcategoryList.count > 0 {
            let orderedDetails = subcategoryList[0].categoryDetails.sorted { $0.guiOrder < $1.guiOrder }
            for detail in orderedDetails {
                guard let type = AddOfferElement(rawValue: detail.type) else { continue }
                if detail.parent == "" {
                    vm.parentsOfView.append(ParentOfView(name: detail.name, selectedValue: offer.details?.first(where: { $0.key == detail.name})?.value ?? ""))
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
                                text: offer.details?.first(where: { $0.key == detail.name})?.value,
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
                                  isFirstSelected: offer.details?.first(where: { $0.key == detail.name})?.value == firstOption)
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
                        let index = dataSource.firstIndex(of: vm.parentsOfView.first { $0.name == detail.name }?.selectedValue ?? "")
                        newView.setDataSource(dataSource: dataSource,
                                              selectedIndex: index,
                                              title: detail.label.translationText, placeholder: detail.placeholder ?? "")
                        newView.doneEditing = { [unowned self] in
                            vm.parentsOfView.first {  $0.name == detail.name }?.selectedValue = newView.selectedText ?? ""
                            //createTotalCategoryDetailsOffer(offer)
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
                        let index = dataSource.firstIndex(of: offer.details?.first(where: { $0.key == detail.name})?.value ?? "")
                        newView.setDataSource(dataSource: dataSource, selectedIndex: index ,title: detail.label.translationText, placeholder: detail.placeholder ?? "")
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
    
    private func createCategoryDetailsOffer(_ offer: OfferDetails) {
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
                            text: offer.details?.first(where: { $0.key == detail.name})?.value,
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
                              isFirstSelected: offer.details?.first(where: { $0.key == detail.name})?.value.lowercased().l10n() == firstOption)
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
                    let index = dataSource.firstIndex(of: offer.details?.first(where: { $0.key == detail.name})?.value ?? "")
                    newView.setDataSource(dataSource: dataSource,
                                          selectedIndex: index,
                                          title: detail.label.translationText, placeholder: detail.placeholder ?? "")
                    newView.doneEditing = { [unowned self] in
                        vm.parentsOfView.first {  $0.name == detail.name }?.selectedValue = newView.selectedText ?? ""
                        //createTotalCategoryDetailsOffer(offer)
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
                    let index = dataSource.firstIndex(of: offer.details?.first(where: { $0.key == detail.name})?.value ?? "")
                    newView.setDataSource(dataSource: dataSource, selectedIndex: index, title: detail.label.translationText, placeholder: detail.placeholder ?? "")
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
