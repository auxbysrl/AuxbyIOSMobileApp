//
//  PreviewOrDetailsVCOwner.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.03.2023.
//

import UIKit
import L10n_swift

extension PreviewOrDetailsVC {
    func setWinnerViewOwner(_ offer: OfferDetails) {
        if offer.status == Offer.offerStatus.finished.status {
            if let bids = offer.bids {
                for bid in bids {
                    if bid.winner {
                        winnerView.isHidden = false
                        winnerName.text = bid.userName
                        if let url = bid.userAvatar {
                            winnerImage.setImage(from: url)
                        } else {
                            winnerImage.image = UIImage(named: Owner.noProfilePhoto)
                        }
                        winnerActive.text = getStringWinner(bid: bid)
                        contactWinnerLabel.text = "contactWinner".l10n()
                        callWinnerAction = {
                            if let phoneNumber = bid.phone {
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
    
    func getStringWinner(bid: Bid)-> String {
        var activeString = ""
        if let _ = vm.offer?.owner {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "ro_RO")
            let lastActiveDate = dateFormatter.date(from: bid.lastSeen)!
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
    
    func setTopViewOwner(_ offer: OfferDetails) {
        reportButton.isHidden = true
        if offer.status == Offer.offerStatus.active.status {
            promoteButton.isHidden = offer.isPromoted
            shareButton.isHidden = false
            deleteButton.isHidden = true
        } else {
            promoteButton.isHidden = true
            shareButton.isHidden = true
            deleteButton.isHidden = false
        }
    }
    
    func setInfoView(_ offer: OfferDetails) {
        infoViewHeight.constant = 35
        infoLabel.isHidden = false
        if offer.isOnAuction {
            if offer.status == Offer.offerStatus.active.status {
                let color: UIColor = .primaryLight.withAlphaComponent(0.6)
                infoView.backgroundColor = color
                infoLabel.text = Offer.offerStatus.active.status.lowercased().l10n()
                infoImageView.image = UIImage(named: Offer.offerStatus.active.status.lowercased())
                closeActionButton.isHidden = false
            } else if offer.status == Offer.offerStatus.interrupted.status {
                let color: UIColor = .red.withAlphaComponent(0.6)
                infoView.backgroundColor = color
                infoLabel.text = Offer.offerStatus.interrupted.status.lowercased().l10n()
                infoImageView.image = UIImage(named: Offer.offerStatus.interrupted.status.lowercased())
                closeActionButton.isHidden = true
            } else if offer.status == Offer.offerStatus.finished.status{
                let color: UIColor = .green.withAlphaComponent(0.6)
                infoView.backgroundColor = color
                infoLabel.text = Offer.offerStatus.finished.status.lowercased().l10n()
                infoImageView.image = UIImage(named: Offer.offerStatus.finished.status.lowercased())
                closeActionButton.isHidden = true
            }
        } else {
            if offer.status == Offer.offerStatus.active.status {
                let color: UIColor = .primaryLight.withAlphaComponent(0.6)
                infoView.backgroundColor = color
                infoImageView.image = UIImage(named: Offer.offerStatus.active.status.lowercased())
                infoLabel.text = Offer.offerStatus.active.status.lowercased().l10n()
                secondButton.setImage(UIImage(named: "disable"), for: .normal)
                secondButton.setTitle("disable".l10n(), for: .normal)
                secondButton.backgroundColor = .textDark
            } else {
                let color: UIColor = .secondary.withAlphaComponent(0.6)
                infoView.backgroundColor = color
                infoLabel.text = Offer.offerStatus.inactive.status.lowercased().l10n()
                infoImageView.image = UIImage(named: Offer.offerStatus.inactive.status.lowercased())
                secondButton.setImage(UIImage(named: "enable"), for: .normal)
                secondButton.setTitle("enable".l10n(), for: .normal)
                secondButton.backgroundColor = .primaryLight
            }
        }
    }
    
    func setIsActionOwner(_ offer: OfferDetails) {
        ownerOfferSV.isHidden = offer.isOnAuction
        setInfoView(offer)
    }
    
    func setBidsLabelOwner(_ offer: OfferDetails) {
        highestBidLabel.text = "\(Int(offer.price).formattedString)\(offer.currencySymbol ?? "")"
        yourBidLabel.textColor = .primaryLight
        yourBidLabel.text = "\(Int(offer.highestBid!).formattedString)\(offer.currencySymbol ?? "")"
        firstLabelForBid.text = "startingPrice".l10n()
        secondLabelForBid.text = "highestBid".l10n()
    }
    
    func setFavoritesNumberOwner(_ offer: OfferDetails) {
        favoriteButton.setImage(UIImage(named: "heartFill"), for: .normal)
        if offer.setAsFavoriteNumber! > 0 {
            favoritesNumberLabel.text = "\(offer.setAsFavoriteNumber!)"
        } else {
            favoritesNumberLabel.isHidden = true
            favoriteSV.backgroundColor = .clear
        }
        favoriteButton.isUserInteractionEnabled = false
        }
}
