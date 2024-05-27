//
//  OfferView.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.11.2022.
//

import UIKit
import L10n_swift

class OfferView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet private var defaultView: UIView!
    @IBOutlet private weak var offerImage: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var lastBidLabel: UILabel!
    @IBOutlet private var usersImages: [UIImageView]!
    @IBOutlet private weak var clockImage: UIImageView!
    @IBOutlet private weak var usersCountLabel: UILabel!
    @IBOutlet private weak var descriptionSV: UIStackView!
    @IBOutlet private weak var usersView: UIView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var currentBidOrPrice: UILabel!
    @IBOutlet private weak var firstImageWidth: NSLayoutConstraint!
    @IBOutlet private weak var secondImageWidth: NSLayoutConstraint!
    @IBOutlet private weak var thirdImageWidth: NSLayoutConstraint!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var extraView: UIView!
    @IBOutlet weak var extraImage: UIImageView!
    @IBOutlet weak var extraLabel: UILabel!
    @IBOutlet weak var lineLabelLeading: NSLayoutConstraint!
    @IBOutlet weak var promoteView: UIView!
    
    // MARK: - Private properties
    private var addToFav: (() -> Void)?
    private var viewOffer: (() -> Void)?
    private var showUsers: (() -> Void)?
    private var offer: Offer!
    private var isFavorite = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    func setView(offer: Offer, addToFav: (() -> Void)?, viewOffers: (() -> Void)?, showUsers: (() -> Void)?) {
        self.offer = offer
        isFavorite = offer.isUserFavorite!
        promoteView.isHidden = !offer.isPromoted
        setExtraView()
        let image = isFavorite ? "favoriteChecked" : "favorite"
        favoriteButton.setImage(UIImage(named: image), for: .normal)
        self.addToFav = addToFav
        self.viewOffer = viewOffers
        self.showUsers = showUsers
        titleLabel.text = offer.title
        locationLabel.text = offer.location
        let descr = offer.description.replacingOccurrences(of: "\n", with: " ")
        descriptionLabel.text = descr
        descriptionSV.isHidden = offer.isOnAuction
        usersView.isHidden = !offer.isOnAuction
        if offer.isOnAuction {
            setDate(offer: offer)
            setUset(offer: offer)
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            dateFormatter.locale = Locale(identifier: "ro_RO")
            let date = dateFormatter.date(from: offer.publishDate!)
            dateLabel.text = date?.toString(format: "dd MMM yyyy")
        }
        currentBidOrPrice.text = offer.isOnAuction ? "currentBid".l10n() : "price".l10n()
        
        let imageName = offer.isOnAuction ? "clock" : "calendar"
        clockImage.image = UIImage(named: imageName)
        if offer.photos!.isEmpty {
            offerImage.image = UIImage(named: "noPhotoImage")
        } else {
            offerImage.setImage(from: offer.photos![0].url!, reload: false)
        }
        var currency = ""
        switch offer.currencyType {
        case "EURO" : currency = "€"
        default: currency = "lei"
        }
        var price = 0
        if offer.isOnAuction {
            price = offer.highestBid == 0 ? Int(offer.price) : Int(offer.highestBid!)
        } else {
            price = Int(offer.price)
        }
        lastBidLabel.text = "\(price.formattedString)" + (currency)
        setPriceTextColor()
    }
    
    // MARK: - IBActions
    @IBAction func viewOffer(_ sender: Any) {
        viewOffer?()
    }
    
    @IBAction func showUsers(_ sender: Any) {
        showUsers?()
    }
    
    @IBAction func addOrRemoveToFavorite(_ sender: Any) {
        addToFav?()
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            isFavorite.toggle()
            let image = isFavorite ? "favoriteChecked" : "favorite"
            favoriteButton.setImage(UIImage(named: image), for: .normal)
            offer.isUserFavorite = isFavorite
            if var favorite = Offline.decode(key: .favorites, type: [Offer].self) {
                if isFavorite {
                    favorite.append(offer!)
                } else {
                    if let index = favorite.firstIndex(where: { $0.id == offer!.id }) {
                        favorite.remove(at: index)
                    }
                }
                Offline.encode(favorite, key: .favorites)
            }
            
            if var offers = Offline.decode(key: .userBids, type: [Offer].self) {
                if let index = offers.firstIndex(where: { $0.id == offer.id }) {
                    let newOffer = offers[index]
                    newOffer.isUserFavorite = isFavorite
                    offers[index] = newOffer
                }
                Offline.encode(offers, key: .userBids)
            }
            
            if var offers = Offline.decode(key: .offers, type: [Offer].self) {
                if let index = offers.firstIndex(where: { $0.id == offer.id }) {
                    let newOffer = offers[index]
                    newOffer.isUserFavorite = isFavorite
                    offers[index] = newOffer
                }
                Offline.encode(offers, key: .offers)
                NotifyCenter.post(.updateOffers)
            }
        }
    }
}

private extension OfferView {
    func setView() {
        Bundle.main.loadNibNamed("Offer", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
    
    func setPriceTextColor() {
        if let user = Offline.currentUser {
            if offer.isOnAuction {
                if offer.highestBid == 0 {
                    lastBidLabel.textColor = .primaryLight
                } else {
                    if let bids = offer.bids {
                        if bids.contains(where: {$0.email == user.email }) {
                            if bids.sorted(by: { $0.bidValue > $1.bidValue }).first?.email == user.email {
                                lastBidLabel.textColor = .green
                            } else {
                                lastBidLabel.textColor = .red
                            }
                        } else {
                            lastBidLabel.textColor = .primaryLight
                        }
                    }
                }
            } else {
                lastBidLabel.textColor = .primaryLight
            }
        }
    }
    
    func setExtraView() {
        if let user = Offline.currentUser {
            if offer.owner?.userName == user.email {
                if offer.status == Offer.offerStatus.active.status {
                    extraView.isHidden = true
                } else if offer.status == Offer.offerStatus.interrupted.status{
                    extraView.isHidden = false
                    promoteView.isHidden = true
                    extraView.backgroundColor = .red.withAlphaComponent(0.8)
                    extraImage.image = UIImage(named: Offer.offerStatus.interrupted.status.lowercased())
                    extraLabel.text = Offer.offerStatus.interrupted.status.lowercased().l10n()
                } else if offer.status == Offer.offerStatus.inactive.status {
                    extraView.isHidden = false
                    promoteView.isHidden = true
                    extraView.backgroundColor = .secondary.withAlphaComponent(0.8)
                    extraImage.image = UIImage(named: Offer.offerStatus.inactive.status.lowercased())
                    extraLabel.text = Offer.offerStatus.inactive.status.lowercased().l10n()
                } else if offer.status == Offer.offerStatus.finished.status {
                    extraView.isHidden = false
                    promoteView.isHidden = true
                    extraView.backgroundColor = .green.withAlphaComponent(0.8)
                    extraImage.image = UIImage(named: Offer.offerStatus.finished.status.lowercased())
                    extraLabel.text = Offer.offerStatus.finished.status.lowercased().l10n()
                }
            }
        }
    }
    
    func setDate(offer: Offer) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ro_RO")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let givenDate = dateFormatter.date(from: offer.auctionEndDate ?? "") else {
            fatalError("Invalid date format")
        }
        if offer.status == Offer.offerStatus.active.status {
            dateFormatter.dateFormat = "EEEE, HH:mm"
            let formattedDateString = dateFormatter.string(from: givenDate)
            let timeInterval = givenDate.timeIntervalSinceNow
            if timeInterval > 0 {
                if timeInterval < 60 * 60 {
                    let minutes = Int(timeInterval / 60)
                    dateLabel.text = " \(minutes)m"
                } else if timeInterval < 24 * 60 * 60 {
                    let remainingTimeInterval = timeInterval.truncatingRemainder(dividingBy: 60 * 60)
                    let hours = Int(timeInterval / (60 * 60))
                    let minutes = Int(remainingTimeInterval / 60)
                    dateLabel.text = "\(hours)h \(minutes)m"
                } else {
                    let days = Int(floor(timeInterval / (24 * 60 * 60)))
                    let remainingTimeInterval = timeInterval.truncatingRemainder(dividingBy: 24 * 60 * 60)
                    let hours = Int(remainingTimeInterval / (60 * 60))
                    dateLabel.text = "\(days)d \(hours)h | \(formattedDateString)"
                }
            } else {
                dateLabel.text = "actionEnded".l10n()
            }
        } else {
            dateLabel.text = "actionEnded".l10n()
        }
    }
    
    func setUset(offer: Offer) {
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
            lineLabelLeading.constant = 10
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
}
