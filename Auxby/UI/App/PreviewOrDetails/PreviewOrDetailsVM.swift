//
//  PreviewOrDetailsVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 25.01.2023.
//

import UIKit
import Combine
import L10n_swift

class PreviewOrDetailsVM {
    
    // MARK: - Public properties
    var isNewOffer: Bool
    var offerPreview: Offer?
    var offer: OfferDetails?
    var newOffer: NewOffer?
    var user: User?
    var id: Int?
    var needToView = true
    var isFirstTime = true
    @Published private(set) var getOfferState = RequestState<OfferDetails>.idle
    @Published private(set) var addOfferState = RequestState<OfferDetails>.idle
    @Published private(set) var changeOfferState = RequestState<SuccessResponse>.idle
    @Published private(set) var getUserState = RequestState<User>.idle
    @Published private(set) var getDeleteOfferState = RequestState<Bool>.idle
    @Published private(set) var getAddToFavoriteState = RequestState<SuccessResponse>.idle
    @Published private(set) var getStartNewChat = RequestState<Chat>.idle
    @Published private(set) var getDeepLinkState = RequestState<OfferDeepLink>.idle
    var categoriesDetails: [CategoryDetails] = []
    var cancellables: Set<AnyCancellable> = []
    var photos: [UIImage] = []
    var publishedAction: (() -> Void)?
    var activatePrice = 0
    var currentImage = 0
    
    init(offer: Offer? = nil , newOffer: NewOffer? = nil, id: Int? = nil) {
        isNewOffer = newOffer != nil
        offerPreview = offer
        self.id = id
        self.newOffer = newOffer
        user = Offline.currentUser
        if let offer = offer {
            if let cat = Offline.decode(key: .categoryDetails, type: [CategoryDetails].self)?.first(where: { $0.id == offer.categoryId}) {
                activatePrice = cat.addOfferCost
            }
        }
    }
    
    func getDeepLink() {
        if let offer = offer {
            getDeepLinkState = .loading
            Network.shared.request(endpoint: .getDeepLink(offerID: offer.id))
                .assign(to: &$getDeepLinkState)
        }
    }
    
    func startNewChat() {
        if let offer = offer {
            getStartNewChat = .loading
            Network.shared.request(endpoint: .startNewChat(offerId: offer.id))
                .assign(to: &$getStartNewChat)
        }
    }
    
    func changeStatus() {
        if let offer = offer {
            changeOfferState = .loading
            Network.shared.request(endpoint: .changeStatus(id: offer.id, requiredCoins: activatePrice))
                    .assign(to: &$changeOfferState)
     
        }
    }
    
    func getOffer() {
        if let offerPreview = offerPreview {
            getOfferState = .loading
            Network.shared.request(endpoint: .getOfferBy(id: offerPreview.id, increaseView: needToView))
                .assign(to: &$getOfferState)
        }
        if let offer = offer {
            getOfferState = .loading
            Network.shared.request(endpoint: .getOfferBy(id: offer.id, increaseView: needToView))
                .assign(to: &$getOfferState)
        }
        if let id = id {
            getOfferState = .loading
            Network.shared.request(endpoint: .getOfferBy(id: id, increaseView: needToView))
                .assign(to: &$getOfferState)
        }
    }
    
    func deleteOffer() {
        if let offer = offer {
            getDeleteOfferState = .loading
            Network.shared.request(endpoint: .deleteOffer(id: offer.id))
                .assign(to: &$getDeleteOfferState)
        }
    }
    
    func addOffer(offer: NewOffer) {
        addOfferState = .loading
        Network.shared.request(endpoint: .addOffer(offer: offer))
            .assign(to: &$addOfferState)
    }
    
    func getUser() {
        getUserState = .loading
        Network.shared.request(endpoint: .getUser)
            .assign(to: &$getUserState)
    }
    
    func addOrRemoveFromFavorite() {
        getAddToFavoriteState = .loading
        Network.shared.request(endpoint: .addOrRemoveFavorite(id: offer!.id))
            .assign(to: &$getAddToFavoriteState)
    }
    
    func addImagesForOffer(images: [UIImage], id: Int) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        if ApiRequest.isProduction {
            urlComponents.port = 8082
        }
        urlComponents.host = ApiRequest.baseURLForOffers
        urlComponents.path = "/api/v1/product/upload/\(id)"
        let finalURL = urlComponents.url ??  URL(string: "https://auxby.ro:8082/api/v1/product/upload/\(id)")!
        var request = URLRequest(url: finalURL)
        let boundary = UUID().uuidString
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let token = Keychain.get(.token)
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        let body = NSMutableData()
        // Add boundary string
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        for image in images {
            guard let imageData = ImageCompresser().compressImage(image) else {
                continue
            }

            // Add boundary string
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            // Add content disposition header
            let fileName = "\(UUID().uuidString).jpg"
            body.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            // Add content type header
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            // Add image data
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body as Data
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending request: \(error.localizedDescription)")
                UIAlert.showOneButton(message: "errorImages".l10n())
                runOnMainThread {
                    self.publishedAction?()
                }
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                UIAlert.showOneButton(message: "errorImages".l10n())
                runOnMainThread {
                    self.publishedAction?()
                }
                return
            }
            if httpResponse.statusCode == 200 {
                runOnMainThread {
                    self.publishedAction?()
                }
            } else {
                UIAlert.showOneButton(message: "errorImages".l10n())
                runOnMainThread {
                    self.publishedAction?()
                }
            }
        }
        task.resume()
    }
}
