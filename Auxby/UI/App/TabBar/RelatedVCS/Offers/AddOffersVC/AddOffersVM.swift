//
//  AddOffersVM.swift
//  Auxby
//
//  Created by Andrei Traciu on 10.01.2023.
//

import UIKit
import Combine
import L10n_swift

class AddOfferVM {
    
    // MARK: Public Properties
    var offer: OfferDetails?
    var category: CategoryDetails = CategoryDetails()
    var subcategories: [String] = []
    var subcategoriesIds: [Int] = []
    var subcategoriesNames: [String] = []
    var selectedSubcategory: String = ""
    var selectedSubcategoryId: Int?
    var parentsOfView: [ParentOfView] = []
    @Published private(set) var editOfferState = RequestState<OfferDetails>.idle
    var cancellables: Set<AnyCancellable> = []
    
    var maxPhotos: Int = 7
    var photos: [UIImage] = []
    var isBidType = false
    
    var title = ""
    var price = ""
    var stopDate = ""
    var location = ""
    var phone = ""
    var description = ""
    var currency = CurrencyType.ron
    var condition = ConditionType.new
    var offerType = OfferType.fixPrice
    var details: [NewOffer.Values] = []
    var imagesAdded: (()->Void)?
    
    convenience init(category: CategoryDetails) {
        self.init()
        self.category = category
        
        subcategories = category.subcategories.map { $0.label.translationText }
        subcategoriesIds = category.subcategories.map { $0.id }
        subcategoriesNames = category.subcategories.map { $0.name }
    }
    
    func editOffer(_ newOffer: NewOffer) {
        editOfferState = .loading
        Network.shared.request(endpoint: .editOffer(offer: newOffer, id: offer?.id ?? 0))
            .assign(to: &$editOfferState)
    }
    
    func addImagesForOffer(images: [UIImage], id: Int) {
        if images.isEmpty {
            self.imagesAdded?()
        } else {
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
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let token = Keychain.get(.token)
            request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
            let body = NSMutableData()
            // Add boundary string
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            for image in images {
                guard let imageData = compressImage(image, maxFileSize: 6 * 1024 * 1024) else {
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
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                if httpResponse.statusCode == 200 {
                    runOnMainThread {
                        topVC().popVC()
                        self.imagesAdded?()
                    }
                } else {
                    UIAlert.showOneButton(message: "errorImages".l10n()) {
                        runOnMainThread {
                            topVC().popVC()
                            self.imagesAdded?()
                        }
                    }
                }
            }
            task.resume()
        }
    }
    
    func compressImage(_ image: UIImage, maxFileSize: Int) -> Data? {
        var compression: CGFloat = 0.9
        var imageData = image.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxFileSize && compression > 0.1 {
            compression -= 0.1
            imageData = image.jpegData(compressionQuality: compression)
        }
        
        return imageData
    }
}

enum OfferType {
    case auction, fixPrice
    var type: String {
        switch self {
        case .auction:
            return "Auction"
        case .fixPrice:
            return "Fix price"
        }
    }
}

enum CurrencyType: String {
    case ron
    case euro
    var type: String {
        switch self {
        case .ron:
            return "Ron"
        case .euro:
            return "Euro"
        }
    }
}

enum ConditionType {
    case new, used
    var type: String {
        switch self {
        case .new:
            return "New"
        case .used:
            return "Used"
        }
    }
}

class ParentOfView {
    var name: String
    var selectedValue: String
    
    init(name: String, selectedValue: String = "") {
        self.name = name
        self.selectedValue = selectedValue
    }
}
