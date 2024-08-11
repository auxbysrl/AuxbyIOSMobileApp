//
//  PreviewOrDetailsVC.swift
//  Auxby
//
//  Created by Eduard Hutu on 10.01.2023.
//

import UIKit
import L10n_swift

class PreviewOrDetailsVC: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var imageSlider: UICollectionView!
    @IBOutlet weak var imagesControl: UIPageControl!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var readMoreOrLessButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var detailsSV: UIStackView!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var priceView: UIView!
    @IBOutlet weak var specificationsView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var contactsView: UIView!
    @IBOutlet weak var socialMediaView: UIView!
    @IBOutlet weak var placeBidButton: UIButton!
    @IBOutlet weak var closeActionButton: UIButton!
    @IBOutlet weak var normalOfferSV: UIStackView!
    @IBOutlet weak var publishSV: UIStackView!
    @IBOutlet weak var ownerOfferSV: UIStackView!
    
    @IBOutlet weak var offerTitleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var firstLabelForBid: UILabel!
    @IBOutlet weak var secondLabelForBid: UILabel!
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var readMoreHeight: NSLayoutConstraint!
    @IBOutlet weak var favoritesNumberLabel: UILabel!
    @IBOutlet weak var favoriteSV: UIStackView!
    @IBOutlet weak var itemNumber: UILabel!
    @IBOutlet weak var bidView: UIView!
    @IBOutlet weak var bidListView: UIView!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var priceTypeLabel: UILabel!
    @IBOutlet weak var listOfBiddersHeight: NSLayoutConstraint!
    @IBOutlet weak var listOfBidders: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoViewHeight: NSLayoutConstraint!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var firstImageWidth: NSLayoutConstraint!
    @IBOutlet weak var secondImageWidth: NSLayoutConstraint!
    @IBOutlet weak var thirdImageWidth: NSLayoutConstraint!
    @IBOutlet weak var usersCountLabel: UILabel!
    @IBOutlet var usersImages: [UIImageView]!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var itemNumberView: UIView!
    
    @IBOutlet weak var highestBidLabel: UILabel!
    @IBOutlet weak var yourBidLabel: UILabel!
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var roundedTestView: UIView!
    @IBOutlet weak var secondButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var alert: AlertView!
    @IBOutlet weak var publishLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fullDescriptionView: UIView!
    @IBOutlet weak var fullDescriptionLabel: UILabel!
    @IBOutlet weak var winnerView: UIView!
    @IBOutlet weak var contactWinnerLabel: UILabel!
    @IBOutlet weak var winnerImage: UIImageView!
    @IBOutlet weak var winnerName: UILabel!
    @IBOutlet weak var winnerActive: UILabel!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var promoteButton: UIButton!
    @IBOutlet var stars: [UIButton]!
    
    
    // MARK: - Public properties
    var previousScrollOffset: CGFloat = 20
    var readMore = false
    var vm: PreviewOrDetailsVM!
    var indicator: ActivityIndicator?
    var callWinnerAction: (()->Void)?
    var messageWinnerAction: (()->Void)?
    var timer: Timer?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !vm.isNewOffer {
            if timer == nil {
                timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { [unowned self] _ in
                    vm.getOffer()
                })
            }
            vm.getOffer()
            vm.user = Offline.currentUser
            if let offer = vm.offer {
                if offer.photos != nil {
                    imageSlider.scrollToItem(at: IndexPath(row: self.vm.currentImage, section: 0), at: .centeredVertically, animated: true)
                }
            }
        } else {
            roundedTestView.roundCorners(corners: [.topLeft,.topRight], radius: 25)
            testView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setObservable()
        if vm.isNewOffer {
            setView()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style: UIStatusBarStyle = .lightContent
    
    
    // MARK: - IBActions
    @IBAction func swipeImage(_ sender: UIPageControl) {
        imageSlider.scrollToItem(at: IndexPath(row: sender.currentPage, section: 0), at: .top, animated: true)
    }
    
    @IBAction func readMoreOrLess(_ sender: UIButton) {
        readMore.toggle()
        fullDescriptionView.isHidden = !readMore
        descriptionView.isHidden = readMore
        contentView.layoutIfNeeded()
    }
    
    @IBAction func back(_ sender: UIButton) {
        popVC()
    }
    
    @IBAction func goToReview(_ sender: UIButton) {
//        if let user = Offline.decode(key: .currentUser, type: User.self) {
//            if !vm.isNewOffer {
//                if let offer = vm.offer, let owner = offer.owner, let userName = owner.userName {
//                    if user.email != userName {
//                        let reviewVC = ReviewVC.asVC()
//                        presentVC(reviewVC)
//                    }
//                }
//            }
//        } else {
//            presentVC(GuestModeVC.asVC())
//        }
        if let offer = vm.offer {
            if let user = vm.user {
                if offer.owner?.userName != user.email {
                    if let owner = offer.owner {
                        let userOffersVC = UserOffersVC.asVC() as! UserOffersVC
                        userOffersVC.vm = UserOffersVM(owner: owner)
                        pushVC(userOffersVC)
                    }
                }
            }
        } 
    }
    
    @IBAction func goToReport(_ sender: UIButton) {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            if !vm.isNewOffer {
                let reportVC = ReportVC.asVC() as! ReportVC
                reportVC.vm = ReportVM(offerID: vm.offer!.id)
                presentVC(reportVC)
            }
        } else {
            presentVC(GuestModeVC.asVC())
        }
    }
    
    @IBAction func publishOffer(_ sender: UIButton) {
        if let newOffer = vm.newOffer {
            if let user = vm.user {
                if user.availableCoins < newOffer.requiredCoins {
                    let title = "notEnoughCoins".l10n()
                    let content = "coinsBalance".l10n() + " \(user.availableCoins)"
                    alert.set(title: title, content: content, secondButtonTitle: "buyMore".l10n())
                    alert.cancel = { [unowned self] in
                        alert.isHidden = true
                    }
                    alert.confirm = { [unowned self] in
                        alert.isHidden = true
                        pushVC(BuyCoinsVC.asVC())
                    }
                    alert.isHidden = false
                } else {
                    let title = "publishFor".l10n() + " \(newOffer.requiredCoins) coins.\n" + "availableFor".l10n()
                    let content = "coinsBalance".l10n() + " \(user.availableCoins)"
                    alert.set(title: title, content: content, secondButtonTitle: "confirm".l10n())
                    alert.cancel = { [unowned self] in
                        alert.isHidden = true
                    }
                    alert.confirm = { [unowned self] in
                        alert.isHidden = true
                        indicator = ActivityIndicator()
                        vm.addOffer(offer: newOffer)
                    }
                    alert.isHidden = false
                }
            }
        }
    }
    
    @IBAction func placeBid(_ sender: UIButton) {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            let placeBidVC = PlaceBidVC.asVC() as! PlaceBidVC
            placeBidVC.vm = PlaceBidVM(offer: vm.offer!)
            placeBidVC.bidPlaced = {
                self.vm.getOffer()
                self.vm.getUser()
            }
            presentVC(placeBidVC)
        } else {
            presentVC(GuestModeVC.asVC())
        }
    }
    
    @IBAction func goToSocial(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            if let url = URL(string: "https://www.facebook.com/profile.php?id=100095265410496") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        case 2:
            if let url = URL(string: "https://instagram.com/auxby.ro?igshid=MzRlODBiNWFlZA==") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        default:
            if let url = URL(string: "https://www.tiktok.com/@auxby.ro?_t=8gcajtfQkLp&_r=1") {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    @IBAction func call(_ sender: UIButton) {
        if sender.tag == 1 {
            callWinnerAction?()
        } else {
            if let _ = Offline.decode(key: .currentUser, type: User.self) {
                if let offer = vm.offer {
                    if let phoneNumber = offer.phoneNumbers {
                        if let url = URL(string: "tel://\(phoneNumber)") {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            } else {
                presentVC(GuestModeVC.asVC())
            }
        }
    }
    
    @IBAction func message(_ sender: UIButton) {
        if sender.tag == 1 {
            messageWinnerAction?()
        } else {
            if let _ = Offline.decode(key: .currentUser, type: User.self) {
                vm.startNewChat()
            } else {
                presentVC(GuestModeVC.asVC())
            }
        }
    }
    
    @IBAction func addOrRemoveFromFavorite(_ sender: UIButton) {
        if let _ = Offline.decode(key: .currentUser, type: User.self) {
            if let offer = vm.offer {
                if var isFavorite = offer.isUserFavorite {
                    isFavorite.toggle()
                    let number = isFavorite ? offer.setAsFavoriteNumber! + 1 : offer.setAsFavoriteNumber! - 1
                    setFavoritesNumberUser(number, isFavorite)
                    offer.isUserFavorite = isFavorite
                    if var favorite = Offline.decode(key: .favorites, type: [Offer].self) {
                        if isFavorite {
                            favorite.append(vm.offer!.toOffer())
                        } else {
                            favorite.remove(at: favorite.firstIndex(where: { $0.id == vm.offer!.toOffer().id })!)
                        }
                        Offline.encode(favorite, key: .favorites)
                        
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
            vm.addOrRemoveFromFavorite()
        } else {
            presentVC(GuestModeVC.asVC())
        }
    }
    
    
    @IBAction func deleteOffer(_ sender: UIButton) {
        alert.setDelete(title: "deleteOffer".l10n(), content: "areYouSureDeleteOffer".l10n(), secondButtonTitle: "confirm".l10n())
        alert.confirm = {
            self.vm.deleteOffer()
        }
        alert.cancel = { [unowned self] in
            alert.isHidden = true
        }
        alert.isHidden = false
    }
    
    @IBAction func promoteOffer(_ sender: UIButton) {
        let promoteVC = PromoteOfferVC.asVC() as! PromoteOfferVC
        promoteVC.vm = PromoteOfferVM(isFromPreview: false, offer: vm.offer?.toOffer())
        pushVC(promoteVC)
    }
    
    
    @IBAction func edit(_ sender: UIButton) {
        if let offer = vm.offer {
            if let editOfferVC = AddOffersVC.asVC(storyboardName: "Offers") as? AddOffersVC {
                if let category = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self)?.first(where: { $0.id == offer.categoryId}) {
                    editOfferVC.vm = AddOfferVM(category: category)
                    editOfferVC.vm.offer = offer
                    pushVC(editOfferVC)
                } else {
                    if let categories = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self) {
                        for cat in categories {
                            if cat.subcategories.map({ $0.id }).contains(offer.categoryId) {
                                editOfferVC.vm = AddOfferVM(category: cat)
                                editOfferVC.vm.offer = offer
                                pushVC(editOfferVC)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func disableOrEnable(_ sender: UIButton) {
        if let offer = vm.offer {
            if offer.status == Offer.offerStatus.inactive.status {
                if let user = vm.user {
                    if user.availableCoins < vm.activatePrice {
                        let title = "notEnoughCoins".l10n()
                        let content = "coinsBalance".l10n() + " \(user.availableCoins)"
                        alert.set(title: title, content: content, secondButtonTitle: "buyMore".l10n())
                        alert.cancel = { [unowned self] in
                            alert.isHidden = true
                        }
                        alert.confirm = { [unowned self] in
                            alert.isHidden = true
                            pushVC(BuyCoinsVC.asVC())
                        }
                        alert.isHidden = false
                    } else {
                        let title = "publishFor".l10n() + " \(vm.activatePrice) coins.\n" + "availableFor".l10n()
                        let content = "coinsBalance".l10n() + " \(user.availableCoins)"
                        alert.set(title: title, content: content, secondButtonTitle: "confirm".l10n())
                        alert.cancel = { [unowned self] in
                            alert.isHidden = true
                        }
                        alert.confirm = { [unowned self] in
                            alert.isHidden = true
                            indicator = ActivityIndicator()
                            vm.changeStatus()
                        }
                        alert.isHidden = false
                    }
                }
            } else if offer.status == Offer.offerStatus.active.status {
                if offer.isOnAuction {
                    alert.setDelete(title: "closeAction".l10n(), content: "areYouSureCloseAction".l10n(), secondButtonTitle: "confirm".l10n())
                } else {
                    alert.setDelete(title: "disableOffer".l10n(), content: "areYouSureDisableOffer".l10n(), secondButtonTitle: "confirm".l10n())
                }
                alert.confirm = {
                    self.vm.changeStatus()
                }
                alert.cancel = { [unowned self] in
                    alert.isHidden = true
                }
                alert.isHidden = false
            }
        }
    }
    
    @IBAction func showBidList(_ sender: UIButton) {
        if let offer = vm.offer {
            if let bids = offer.bids {
                if !bids.isEmpty {
                    let biddersListVC = ListOfBiddersVC.asVC() as! ListOfBiddersVC
                    biddersListVC.vm = ListOfBiddersVM(bids: bids.sorted(by: {$0.bidValue > $1.bidValue}), currencySymbol: offer.currencySymbol ?? "")
                    presentVC(biddersListVC)
                }
            }
        }
    }
    
    @IBAction func showInfo(_ sender: UIButton) {
        UIAlert.showOneButton(message: "infoMessage".l10n())
    }
    
    
    @IBAction func shareOffer(_ sender: UIButton) {
        if let offer = vm.offer {
            if let urlString = offer.deepLink {
                if urlString.isEmpty {
                    vm.getDeepLink()
                } else {
                    guard let url = URL(string: urlString) else {
                        print("Invalid URL")
                        return
                    }
                    
                    let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    
                    // Exclude irrelevant activity types if necessary
                    activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .print]
                    
                    // For iPad, configure the popover presentation controller
                    if let popoverController = activityViewController.popoverPresentationController {
                        popoverController.sourceView = self.view // Adjust sourceView to a relevant view in your app
                        popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                        popoverController.permittedArrowDirections = []
                    }
                    
                    self.present(activityViewController, animated: true, completion: nil)
                }
                
            } else {
                vm.getDeepLink()
            }
        }
        
    }
}

private extension PreviewOrDetailsVC {
    func setView() {
        setViewExtra()
        setFavoritesNumber()
        setDetailsSV()
        setBidsLabel()
        setImages()
        setTitleAndExtra()
        setPrice()
        setDescription()
        setOwner()
        setBidList()
        setIsAction()
        setTopView()
        setWinnerView()
        setUserView()
    }
    
    func setUserView() {
        if let offer = vm.offer {
            if let user = vm.user {
                if offer.owner?.userName != user.email {
                    userView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showUserOffers)))
                }
            }
        }
    }
    
    @objc func showUserOffers() {
        if let offer = vm.offer {
            if let owner = offer.owner {
                let userOffersVC = UserOffersVC.asVC() as! UserOffersVC
                userOffersVC.vm = UserOffersVM(owner: owner)
                pushVC(userOffersVC)
            }
        }
    }
    
    func setWinnerView() {
        if let offer = vm.offer {
            if let user = vm.user {
                if offer.owner?.userName == user.email {
                    setWinnerViewOwner(offer)
                } else {
                    setWinnerViewWinner(offer)
                }
            }
        }
    }
    
    func setTopView() {
        if let offer = vm.offer {
            if let user = vm.user {
                if offer.owner?.userName == user.email {
                    setTopViewOwner(offer)
                }
            }
        }
    }
    
    func setViewExtra() {
        vm.publishedAction = { [unowned self] in
            indicator = nil
            popVC(3)
            let promoteVC = PromoteOfferVC.asVC() as! PromoteOfferVC
            promoteVC.vm = PromoteOfferVM(isFromPreview: false, offer: vm.offer?.toOffer())
            pushVC(promoteVC)
        }
    }
    
    func setObservable() {
        NotifyCenter.observable(for: .updateUser).sink { [unowned self] in
            vm.user = Offline.currentUser
            setView()
        }.store(in: &vm.cancellables)
        
        vm.$getDeepLinkState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let response):
                guard let url = URL(string: response.url) else {
                    print("Invalid URL")
                    return
                }
                
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                
                // Exclude irrelevant activity types if necessary
                activityViewController.excludedActivityTypes = [.addToReadingList, .assignToContact, .print]
                
                // For iPad, configure the popover presentation controller
                if let popoverController = activityViewController.popoverPresentationController {
                    popoverController.sourceView = self.view // Adjust sourceView to a relevant view in your app
                    popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                    popoverController.permittedArrowDirections = []
                }
                
                self.present(activityViewController, animated: true, completion: nil)
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getAddToFavoriteState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                vm.getOffer()
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getStartNewChat.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed(let chat):
                let conversationVC = ConversationVC.asVC() as! ConversationVC
                conversationVC.vm = ConversationVM(chat: chat)
                pushVC(conversationVC)
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                print(err.localizedDescription)
            default:
                break
            }
        }.store(in: &vm.cancellables)
        
        vm.$changeOfferState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                vm.getUser()
                vm.getOffer()
                NotifyCenter.post(.updateOffers)
                alert.isHidden = true
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
        
        vm.$getDeleteOfferState.sink { [unowned self] state in
            state.setStateActivityIndicator(&indicator)
            switch state {
            case .succeed:
                alert.isHidden = true
                NotifyCenter.post(.updateOffers)
                popVC()
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
        
        vm.$getOfferState.sink { [unowned self] state in
            if vm.isFirstTime {
                state.setStateActivityIndicator(&self.indicator)
            }
            switch state {
            case .succeed(let offer):
                Offline.delete(key: .offerIdFromURL)
                vm.isFirstTime = false
                vm.needToView = false
                vm.offer = offer
                setView()
                if let _ = vm.user {
                    NotifyCenter.post(.updateNotifications)
                }
                delay(0.1) {
                    self.testView.isHidden = true
                }
            case .failed(let err):
                if err.errorStatus == 404 {
                    UIAlert.showOneButton(message: "listingNotAvailable".l10n()) {
                        self.popVC()
                    }
                } else {
                    //UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$addOfferState.sink { [unowned self] state in
            switch state {
            case .succeed(let offer):
                vm.getUser()
                vm.offer = offer
                if vm.photos.count > 0 {
                    vm.addImagesForOffer(images: vm.photos, id: offer.id)
                } else {
                    indicator = nil
                    vm.publishedAction?()
                }
            case .failed(let err):
                if err.errorStatus == 403 {
                    UIAlert.showOneButton(message: "expireToken".l10n())
                    
                } else {
                    UIAlert.showOneButton(message: "somethingWentWrong".l10n())
                }
                indicator?.hide()
                indicator = nil
                print(err.localizedDescription)
            default: break
            }
        }.store(in: &vm.cancellables)
        
        vm.$getUserState.sink { [unowned self] state in
            switch state {
            case.succeed(let user):
                Offline.encode(user, key: .currentUser)
                vm.user = user
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
    }
    
    func setBidsLabel() {
        if let offer = vm.offer {
            if offer.isOnAuction {
                if let user = vm.user {
                    if offer.owner?.userName == user.email {
                        setBidsLabelOwner(offer)
                    } else {
                        setBidsLabelUser(offer)
                    }
                } else {
                    setBidsLabelUser(offer)
                }
            }
        }
    }
    
    func setIsAction() {
        if let offer = vm.offer {
            if let user = vm.user {
                if offer.owner?.userName == user.email {
                    setIsActionOwner(offer)
                } else {
                    setIsActionUser(offer)
                }
            } else {
                setIsActionUser(offer)
            }
        } else {
            setIsActionNewOffer()
        }
    }
    
    func setImages() {
        if let offer = vm.offer {
            setImagesUser(offer)
        } else {
            setImagesNewOffer()
        }
    }
    
    func setTitleAndExtra() {
        if let offer = vm.offer {
            setTitleAndExtraUser(offer)
        } else if let newOffer = vm.newOffer {
            setTitleAndExtraNewOffer(newOffer)
        }
    }
    
    func setPrice() {
        if let offer = vm.offer {
            setPriceUser(offer)
        } else if let newOffer = vm.newOffer {
            setPriceNewOffer(newOffer)
        }
    }
    
    func setDescription() {
        if let offer = vm.offer {
            setDescriptionUser(offer)
        } else if let newOffer = vm.newOffer {
            setDescriptionNewOffer(newOffer)
        }
    }
    
    func setFavoritesNumber() {
        if let offer = vm.offer {
            if let user = vm.user {
                if offer.owner?.userName == user.email {
                    setFavoritesNumberOwner(offer)
                } else {
                    setFavoritesNumberUser(offer.setAsFavoriteNumber!, offer.isUserFavorite!)
                }
            } else {
                setFavoritesNumberUser(offer.setAsFavoriteNumber!, offer.isUserFavorite!)
            }
        } else if vm.newOffer != nil {
            setFavoritesNumberNewOffer()
        }
        
    }
    
    func setOwner() {
        if let offer = vm.offer {
            setOwnerUser(offer)
            stars.forEach {
                let imageName = $0.tag <= offer.owner!.rating ? "starFilled" : "star"
                $0.setImage(UIImage(named: imageName), for: .normal)
            }
        } else if let owner = Offline.decode(key: .currentUser, type: User.self) {
            setOwnerNewOffer(owner)
            stars.forEach {
                let imageName = $0.tag <= owner.rating ? "starFilled" : "star"
                $0.setImage(UIImage(named: imageName), for: .normal)
            }
        }
    }
    
    func setBidList() {
        if let offer = vm.offer {
            setBidsListUser(offer)
        } else if let newOffer = vm.newOffer {
            setBidsListNewOffer(newOffer)
        }
    }
    
    func setDetailsSV() {
        delay(0.1) {
            self.detailsView.roundCorners(corners: [.topLeft,.topRight], radius: 25)
        }
        detailsSV.removeAllSubviews()
        if let offer = vm.offer {
            if let details = offer.details {
                SetDetailsSVUser(details)
            }
        } else if let newOffer = vm.newOffer {
            setDetailsSVNewOffer(newOffer)
        }
    }
    
    func setTopBar(isScrolled: Bool) {
        style = isScrolled ? .darkContent : .lightContent
        setNeedsStatusBarAppearanceUpdate()
        let color: UIColor = isScrolled ? .white : .clear
        UIView.animate(withDuration: 0.5, delay: 0) {
            self.topView.backgroundColor = color
        }
        if let offer = vm.offer {
            titleLabel.text = isScrolled ? offer.title : ""
        } else {
            titleLabel.text = isScrolled ? vm.newOffer?.title : ""
        }
    }
}

extension PreviewOrDetailsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - previousScrollOffset - topView.frame.height
        setTopBar(isScrolled: scrollDiff >= topView.frame.height)
    }
}

extension PreviewOrDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let offer = vm.offer {
            return offer.photos!.count > 0 ? offer.photos!.count : 1
        } else {
            return vm.photos.count > 0 ? vm.photos.count : 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCVCell.className, for: indexPath) as! ImageCVCell
        if let offer = vm.offer {
            if offer.photos!.count > 0 {
                cell.setCell(image: offer.photos![indexPath.row].url)
            } else {
                cell.setCell()
            }
        } else {
            if vm.photos.count > 0 {
                cell.setCell(newImage: vm.photos[indexPath.row])
            }
            else {
                cell.setCell()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let offer = vm.offer {
            if offer.photos!.count > 0 {
                let imagesVC = ImagesSliderVC.asVC() as! ImagesSliderVC
                imagesVC.vm = vm
                pushVC(imagesVC)
            }
        } else {
            if vm.photos.count > 0 {
                let imagesVC = ImagesSliderVC.asVC() as! ImagesSliderVC
                imagesVC.vm = vm
                pushVC(imagesVC)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        visibleRect.origin = imageSlider.contentOffset
        visibleRect.size = imageSlider.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = imageSlider.indexPathForItem(at: visiblePoint) else { return }
        imagesControl.currentPage = indexPath.row
        vm.currentImage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: imageSlider.frame.width, height: imageSlider.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        CGFloat(0)
    }
}
