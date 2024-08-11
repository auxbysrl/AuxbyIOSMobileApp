//
//  PreviewOrDetailsVCNewOffer.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.03.2023.
//

import UIKit
import L10n_swift
extension PreviewOrDetailsVC {
    func setIsActionNewOffer() {
        publishSV.isHidden = false
        publishLabel.text = "publish".l10n() + " \(vm.newOffer!.requiredCoins) coins"
        infoViewHeight.constant = 35
        infoLabel.isHidden = false
        let color: UIColor = .primaryLight.withAlphaComponent(0.6)
        infoView.backgroundColor = color
        infoImageView.isHidden = true
    }
    
    func setFavoritesNumberNewOffer() {
        favoriteSV.isHidden = true
        reportButton.isHidden = true
        shareButton.isHidden = true
    }
    
    func setImagesNewOffer() {
        imagesControl.numberOfPages = vm.photos.count
        imagesControl.currentPage = 0
        imagesControl.currentPageIndicatorTintColor = .secondary
        let color: UIColor = .secondary.withAlphaComponent(0.5)
        imagesControl.pageIndicatorTintColor = color
        imageSlider.reloadData()
    }
    
    func setTitleAndExtraNewOffer(_ newOffer: NewOffer) {
        offerTitleLabel.text = newOffer.title
        locationLabel.text = newOffer.contactInfo.location
        dateLabel.text = Date().toString(format: "dd MMMM yyyy")
        viewsLabel.text = "0 views"
        itemNumber.isHidden = true
    }
    
    func setPriceNewOffer(_ newOffer: NewOffer) {
        if newOffer.offerType == OfferType.auction.type {
            priceTypeLabel.text = "startingPrice".l10n()
            bidListView.isHidden = false
            listOfBiddersHeight.constant = 0
            listOfBidders.isHidden = true
        } else {
            priceTypeLabel.text = "price".l10n()
            bidListView.isHidden = true
        }
        bidView.isHidden = true
        var currency = ""
        if let currencies = Offline.decode(key: .currencies, type: [Currency].self) {
            if let currentCurrency = currencies.first(where: { $0.name == newOffer.currencyType }) {
                currency = currentCurrency.symbol
            }
        }
        priceLabel.text = Int(newOffer.price).formattedString + (currency)
    }
    
    func setDescriptionNewOffer(_ newOffer: NewOffer) {
        descriptionLabel.text = newOffer.description
        fullDescriptionLabel.text = newOffer.description
        delay(0.1) {
            delay(0.1) {
                self.fullDescriptionView.isHidden = !self.readMore
                self.descriptionView.isHidden = self.readMore
            }
        }
        let labelSize = CGSize(width: descriptionLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let textSize = descriptionLabel.text?.boundingRect(with: labelSize, options: options, attributes: [NSAttributedString.Key.font: descriptionLabel.font!], context: nil)
        let numberOfLines = Int(ceil(textSize?.size.height ?? 0) / descriptionLabel.font.lineHeight)
        readMoreOrLessButton.isHidden = numberOfLines < 5
        readMoreHeight.constant = numberOfLines < 5 ? 0 : 24
    }
    
    func setOwnerNewOffer( _ owner: User) {
        if let avatar = owner.avatar {
            userPhoto.setImage(from: avatar)
        } else {
            userPhoto.image = UIImage(named: Owner.noProfilePhoto)
        }
        userNameLabel.text = "\(owner.lastName) \(owner.firstName)"
        lastSeenLabel.text = "active".l10n() +  " " + "today".l10n()
    }
    
    func setBidsListNewOffer(_ newOffer: NewOffer) {
        if newOffer.offerType == OfferType.auction.type {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let givenDate = dateFormatter.date(from: vm.newOffer!.auctionEndDate!) else {
                fatalError("Invalid date format")
            }
            dateFormatter.dateFormat = "EEEE, HH:mm"
            let formattedDateString = dateFormatter.string(from: givenDate)
            let timeInterval = givenDate.timeIntervalSinceNow
            if timeInterval > 0 {
                if timeInterval < 60 * 60 {
                    let minutes = Int(timeInterval / 60)
                    endDateLabel.text = " \(minutes)m"
                } else if timeInterval < 24 * 60 * 60 {
                    let remainingTimeInterval = timeInterval.truncatingRemainder(dividingBy: 60 * 60)
                    let hours = Int(timeInterval / (60 * 60))
                    let minutes = Int(remainingTimeInterval / 60)
                    endDateLabel.text = "\(hours)h \(minutes)m"
                } else {
                    let days = Int(floor(timeInterval / (24 * 60 * 60)))
                    let remainingTimeInterval = timeInterval.truncatingRemainder(dividingBy: 24 * 60 * 60)
                    let hours = Int(remainingTimeInterval / (60 * 60))
                    endDateLabel.text = "\(days)d \(hours)h | \(formattedDateString)"
                }
            }
        }
    }
    
    func setDetailsSVNewOffer(_ newOffer: NewOffer) {
        if let category = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self)?.first(where: { $0.id == newOffer.categoryId }) {
            var details = newOffer.categoryDetails
            let value = newOffer.conditionType.uppercased() == ConditionType.new.type.uppercased() ? "addOffer_new".l10n() : "addOffer_used".l10n()
            details.append(NewOffer.Values(key: "condition".l10n(), value: value))
            if details.isEmpty {
                specificationsView.isHidden = true
            }
            var k = 0
            if details.count > 1 {
                for _ in 1...(details.count / 2) {
                    k += 2
                    let newStack = UIStackView()
                    newStack.axis = .horizontal
                    newStack.alignment = .fill
                    newStack.distribution = .fillEqually
                    newStack.spacing = 10
                    let title = category.categoryDetails.first { $0.name == details[k-2].key }?.label.first(where: { $0.language == L10n.shared.language })?.translation ?? "condition".l10n()
                    let firstView: DetailsCell = DetailsCell.fromNib()
                    firstView.setCell(title: title, content: details[k-2].value)
                    let secondView: DetailsCell = DetailsCell.fromNib()
                    let title2 = category.categoryDetails.first { $0.name == details[k-1].key }?.label.first(where: { $0.language == L10n.shared.language })?.translation ?? "condition".l10n()
                    secondView.setCell(title: title2, content: details[k-1].value)
                    newStack.addArrangedSubview(firstView)
                    newStack.addArrangedSubview(secondView)
                    detailsSV.addArrangedSubview(newStack)
                }
            }
            if details.count % 2 != 0 {
                let newStack = UIStackView()
                newStack.axis = .horizontal
                newStack.alignment = .fill
                newStack.distribution = .fillEqually
                newStack.spacing = 10
                let firstView: DetailsCell = DetailsCell.fromNib()
                let title = category.categoryDetails.first { $0.name == details[details.count - 1].key }?.label.first(where: { $0.language == L10n.shared.language })?.translation ?? "condition".l10n()
                firstView.setCell(title: title, content: details[details.count - 1].value)
                newStack.addArrangedSubview(firstView)
                detailsSV.addArrangedSubview(newStack)
            }
        }
    }
}
