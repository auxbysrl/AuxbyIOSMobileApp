//
//  PreviewOrDetailsVCUser.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.03.2023.
//

import UIKit
import L10n_swift
import NVActivityIndicatorView

extension PreviewOrDetailsVC {
   
    func setWinnerViewWinner(_ offer: OfferDetails) {
        if offer.status == Offer.offerStatus.finished.status {
            if let bids = offer.bids {
                for bid in bids {
                    if bid.winner && bid.email == vm.user?.email {
                        winnerView.isHidden = false
                        winnerName.text = "\(offer.owner?.firstName ?? "") \(offer.owner?.lastName ?? "")"
                        if let url = offer.owner?.avatarUrl {
                            winnerImage.setImage(from: url)
                        } else {
                            winnerImage.image = UIImage(named: Owner.noProfilePhoto)
                        }
                        winnerActive.text = getString()
                        contactWinnerLabel.text = "contactOwner".l10n()
                        callWinnerAction = {
                            if let phoneNumber = offer.phoneNumbers {
                                if let url = URL(string: "tel://\(phoneNumber)") {
                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                }
                            }
                        }
                        
                        messageWinnerAction = { [unowned self] in
                            vm.startNewChat()
                        }
                    }
                }
            }
        }
    }
    
    func setIsActionUser(_ offer: OfferDetails) {
        if offer.status == Offer.offerStatus.active.status {
            placeBidButton.isHidden = !offer.isOnAuction
            ownerOfferSV.isHidden = true
            normalOfferSV.isHidden = offer.isOnAuction
        } else {
            placeBidButton.isHidden = true
            normalOfferSV.isHidden = true
        }
        infoViewHeight.constant = 0
        infoLabel.isHidden = true
        infoImageView.isHidden = true
    }
    
    func setFavoritesNumberUser(_ favoriteNumber: Int, _ isFavorite: Bool) {
        let image = isFavorite ? "heartFill" : "heart"
        favoriteButton.setImage(UIImage(named: image), for: .normal)
        favoritesNumberLabel.isHidden = favoriteNumber <= 0
        let color: UIColor = favoriteNumber <= 0 ? .clear : .white
        favoriteSV.backgroundColor = color
        if favoriteNumber > 0 {
            favoritesNumberLabel.text = "\(favoriteNumber)"
        }
    }
    
    func setBidsLabelUser(_ offer: OfferDetails) {
        var price = offer.highestBid == 0 ? Int(offer.price) : Int(offer.highestBid!)
        highestBidLabel.text = "\(price.formattedString)\(offer.currencySymbol ?? "")"
        price = 0
        offer.bids?.forEach{
            if let user = vm.user {
                let userName = "\(user.firstName) \(user.lastName)"
                if $0.userName == userName {
                    if Int($0.bidValue) > price {
                        price = Int($0.bidValue)
                    }
                }
            }
        }
        let color: UIColor = price == 0 ? .primaryLight : price == Int(offer.highestBid!) ? .green : .red
        yourBidLabel.textColor = color
        yourBidLabel.text = price == 0 ? "-" : "\(price.formattedString)\(offer.currencySymbol ?? "")"
    }
    
    func setImagesUser(_ offer: OfferDetails) {
        imagesControl.numberOfPages = offer.photos?.count ?? 1
        imagesControl.currentPage = vm.currentImage
        imagesControl.currentPageIndicatorTintColor = .secondary
        let color: UIColor = .secondary.withAlphaComponent(0.5)
        imagesControl.pageIndicatorTintColor = color
        imageSlider.reloadData()
    }
    
    func setTitleAndExtraUser(_ offer: OfferDetails) {
        offerTitleLabel.text = offer.title
        locationLabel.text = offer.location
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ro_RO")
        let date = dateFormatter.date(from: offer.publishDate!)
        dateLabel.text = date?.toString(format: "dd MMMM yyyy")
        viewsLabel.text = "\(offer.viewsNumber ?? 0) views"
        itemNumber.text = "itemNO".l10n() + " " + "\(offer.id)"
    }
    
    func setPriceUser(_ offer: OfferDetails) {
        if offer.isOnAuction {
            priceView.isHidden = true
        } else {
            bidView.isHidden = true
            priceLabel.text = Int(offer.price).formattedString + (offer.currencySymbol ?? "")
        }
    }
    
    func setDescriptionUser(_ offer: OfferDetails) {
        descriptionLabel.text = offer.description
        fullDescriptionLabel.text = offer.description
        delay(0.1) {
            self.fullDescriptionView.isHidden = !self.readMore
            self.descriptionView.isHidden = self.readMore
        }
        let labelSize = CGSize(width: descriptionLabel.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let textSize = descriptionLabel.text?.boundingRect(with: labelSize, options: options, attributes: [NSAttributedString.Key.font: descriptionLabel.font!], context: nil)
        let numberOfLines = Int(ceil(textSize?.size.height ?? 0) / descriptionLabel.font.lineHeight)
        readMoreOrLessButton.isHidden = numberOfLines < 5
        readMoreHeight.constant = numberOfLines < 5 ? 0 : 24
    }
    
    func setOwnerUser(_ offer: OfferDetails) {
        if let owner = offer.owner {
            if let avatar = owner.avatarUrl {
                userPhoto.setImage(from: avatar)
            } else {
                userPhoto.image = UIImage(named: Owner.noProfilePhoto)
            }
            userNameLabel.text = "\(owner.lastName ?? "") \(owner.firstName ?? "")"
            lastSeenLabel.text = getString()
        }
    }
    
    func setBidsListUser(_ offer: OfferDetails) {
        setUser(offer: offer)
        bidListView.isHidden = !offer.isOnAuction
        if offer.status == Offer.offerStatus.active.status {
            if offer.isOnAuction {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                dateFormatter.locale = Locale(identifier: "ro_RO")
                guard let givenDate = dateFormatter.date(from: offer.auctionEndDate ?? "") else {
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
                } else {
                    endDateLabel.text = "actionEnded".l10n()
                }
            }
        } else {
            endDateLabel.text = "actionEnded".l10n()
        }
    }
    
    func SetDetailsSVUser(_ detailsList: [Details]) {
        if let category = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self)?.first(where: { $0.id == vm.offer?.categoryId }) {
            var details = detailsList
            let value = vm.offer?.condition?.uppercased() == ConditionType.new.type.uppercased() ? "addOffer_new".l10n() : "addOffer_used".l10n()
            details.append(Details(key: "condition".l10n(), value: value))
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
                    let title2 = category.categoryDetails.first { $0.name == details[k-1].key }?.label.first(where: { $0.language == L10n.shared.language })?.translation ?? "condition".l10n()
                    let secondView: DetailsCell = DetailsCell.fromNib()
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
    
    func setUser(offer: OfferDetails) {
        var listOfBidders: [Bid] = []
        var sortedOffers = offer.bids!
        sortedOffers = sortedOffers.sorted { firstBid, secondBid in
            firstBid.bidValue > secondBid.bidValue
        }
        sortedOffers.forEach { bid in
            if listOfBidders.firstIndex(where: {$0.email == bid.email }) == nil {
                listOfBidders.append(bid)
            }
        }
        switch listOfBidders.count {
        case 0:
            firstImageWidth.constant = 0
            secondImageWidth.constant = 0
            thirdImageWidth.constant = 0
            usersCountLabel.text = "-"
        case 1:
            firstImageWidth.constant = 25
            secondImageWidth.constant = 0
            thirdImageWidth.constant = 0
            usersCountLabel.text = ""
            usersImages.forEach {
                if $0.tag == 0 {
                    if let url = listOfBidders[0].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                }
            }
        case 2:
            firstImageWidth.constant = 25
            secondImageWidth.constant = 25
            thirdImageWidth.constant = 0
            usersCountLabel.text = ""
            usersImages.forEach {
                if $0.tag == 0 {
                    if let url = listOfBidders[0].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                } else if $0.tag == 1 {
                    if let url = listOfBidders[1].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                }
            }
        case 3:
            firstImageWidth.constant = 25
            secondImageWidth.constant = 25
            thirdImageWidth.constant = 25
            usersCountLabel.text = ""
            usersImages.forEach {
                if $0.tag == 0 {
                    if let url = listOfBidders[0].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                } else if $0.tag == 1 {
                    if let url = listOfBidders[1].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                } else if $0.tag == 2 {
                    if let url = listOfBidders[2].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                }
            }
        default:
            firstImageWidth.constant = 25
            secondImageWidth.constant = 25
            thirdImageWidth.constant = 25
            usersCountLabel.text = "and \(listOfBidders.count - 3) more"
            usersImages.forEach {
                if $0.tag == 0 {
                    if let url = listOfBidders[0].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                } else if $0.tag == 1 {
                    if let url = listOfBidders[1].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                } else if $0.tag == 2 {
                    if let url = listOfBidders[2].userAvatar {
                        $0.setImage(from: url)
                    } else {
                        $0.image = UIImage(named: User.noProfilePhoto)
                    }
                }
            }
        }
    }
    
    func getString()-> String {
        var activeString = ""
        if let owner = vm.offer?.owner {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "ro_RO")
            let lastActiveDate = dateFormatter.date(from: owner.lastSeen!)!
            let calendar = Calendar.current
            if calendar.isDateInToday(lastActiveDate) {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                activeString = "active".l10n() +  " " + "today".l10n() + " " + "at".l10n() +  " \(formatter.string(from: lastActiveDate))"
            } else if calendar.isDateInYesterday(lastActiveDate) {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                activeString = "active".l10n() +  " " + "yesterday".l10n() + " " + "at".l10n() +  " \(formatter.string(from: lastActiveDate))"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                activeString = "active".l10n() + " \(formatter.string(from: lastActiveDate))"
            }
        }
        return activeString
    }
}
