//
//  Request.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//


import Foundation
import UIKit

enum ApiRequest {
    
    /// The base URL for all the requests
    static let isProduction = false
    static let baseURL = isProduction ? "auxby.ro" : "auxby.hypercode.ro"
    static let baseURLForOffers = isProduction ? "auxby.ro" : "auxby.hypercode.ro"
  
    // USER
    case checkEmail(email: String)
    case resendLink(email: String)
    case forgotPassword(email: String)
    case create(user: User, pass: String)
    case login(email: String, pass: String)
    case logout
    case loginGoogle(token: String)
    case loginApple(authCode: String, firstName: String, lastName: String)
    case getUser
    case updateUser(user: User)
    case delete
    case saveApnsToken
    case changePassword(oldPassword: String, newPassword: String)
    case finishTransaction(coins: String, price: String, productName: String)
    
    // CATEGORIES
    case getCategories
    case getCategoriesDetails
    case searchPerCategory(text: String)
    
    // OFFERS
    case getOfferBy(id: Int, increaseView: Bool)
    case getOffers(page: Int)
    case getOffersByCategory(categoryID: Int, page: Int)
    case addOffer(offer: NewOffer)
    case editOffer(offer: NewOffer, id: Int)
    case placeBid(id: Int, amount: Int, requiredCoind: Int)
    case addOrRemoveFavorite(id: Int)
    case getOffersByIDs(ids: [Int])
    case getFavorites
    case getUserOffers
    case getUserBids
    case deleteOffer(id: Int)
    case reportOffer(id: Int, type: String, comment: String)
    case changeStatus(id: Int, requiredCoins: Int)
    case searchOffers(search: SearchByCategory)
    case searchOffersWithFilter(search: SearchWithFilter)
    case getPromoted
    case promoteOffer(offerID: Int, expirationDate: String, requiredCoins: Int)
    case getDeepLink(offerID: Int)
    case getOwnerOffers(email: String, page: Int)
    
    // CHAT
    case startNewChat(offerId: Int)
    case getUserChats
    case getMessages(chatID: Int)
    case sendMessage(message: String, chatID: Int)
    
    // NOTIFICATIONS
    case getAllNotifications
    case deleteNotification(id: Int)
    case getCurrencies
    case getAdds
    
    /// API method
    var method: HTTPMethod {
        switch self {
        case .login, .forgotPassword, .create, .resendLink, .addOffer, .placeBid, .addOrRemoveFavorite, .loginGoogle, .reportOffer, .searchOffers, .searchOffersWithFilter, .startNewChat, .sendMessage, .saveApnsToken, .logout, .finishTransaction, .promoteOffer, .loginApple:
            return .post
        case .updateUser, .editOffer, .changeStatus, .changePassword:
            return .put
        case .delete, .deleteOffer, .deleteNotification:
            return .delete
        default:
            return .get
        }
    }
    
    /// API path
    var path: String {
        switch self {
        case .getAdds: return "/api/v1/ads"
        case .getDeepLink(let offerID): return "/api/v1/product/generate-deep-link/\(offerID)"
        case .getCurrencies: return "/api/v1/application/currencies"
        case .promoteOffer(let offerID, _, _): return "/api/v1/product/\(offerID)/promote"
        case .getPromoted: return "/api/v1/product/promoted"
        case .finishTransaction: return "/api/v1/transaction"
        case .logout: return "/api/v1/user/logout"
        case .saveApnsToken: return "/api/v1/user/device-token"
        case .create: return "/api/v1/auth/register"
        case .delete: return "/api/v1/user"
        case .getUser: return "/api/v1/user"
        case .updateUser: return "/api/v1/user"
        case .login: return "/api/v1/auth/login"
        case .addOffer: return "/api/v1/product"
        case .getOffers: return "/api/v1/product"
        case .placeBid: return "/api/v1/product/bid"
        case .forgotPassword: return "/api/v1/auth/send-reset-password"
        case .searchOffers: return "/api/v1/product/search"
        case .loginGoogle: return "/api/v1/auth/google-authentication"
        case .loginApple: return "/api/v1/auth/apple-authentication"
        case .getOffersByCategory: return "/api/v1/product"
        case .checkEmail: return "/api/v1/user/email/check"
        case .changePassword: return "/api/v1/user/password"
        case .getFavorites: return "/api/v1/product/favorites"
        case .getCategories: return "/api/v1/product/category"
        case .getOffersByIDs: return "/api/v1/product/getByIds"
        case .getOfferBy(let id, _): return "/api/v1/product/\(id)"
        case .getOwnerOffers: return "/api/v1/product"
        case .getUserChats: return "/api/v1/chat"
        case .startNewChat: return "/api/v1/chat"
        case .deleteOffer(let id): return "/api/v1/product/\(id)"
        case .editOffer(_, let id): return "/api/v1/product/\(id)"
        case .getUserBids: return "/api/v1/product/my-bids/offers"
        case .getUserOffers: return "/api/v1/product/user/my-offers"
        case .searchOffersWithFilter: return "/api/v1/product/search"
        case .searchPerCategory: return "/api/v1/product/search-summary"
        case .getCategoriesDetails: return "/api/v1/category/details"
        case .resendLink: return "/api/v1/auth/send-confirmation-email"
        case .reportOffer(let id, _, _): return "/api/v1/user/\(id)/report"
        case .addOrRemoveFavorite(let id): return "/api/v1/product/\(id)/favorite"
        case .sendMessage(_ , let id): return "/api/v1/chat/\(id)"
        case .changeStatus(let id, _) : return "/api/v1/product/\(id)/changeStatus"
        case .getMessages(let chatID): return "/api/v1/chat/\(chatID)"
        case .getAllNotifications: return "/api/v1/notifications"
        case .deleteNotification(let id): return "/api/v1/notifications/\(id)"
        }
    }
    
    /// Request body
    var body: [String: Any?]? {
        switch self {
        case .login(let email, let pass):
            return [
                "email": email,
                "password": pass,
            ]
            
        case .loginGoogle(let token):
            return [
                "token": token
            ]
            
        case .loginApple(let authCode, let firstName, let lastName):
            return [
                "authorizationCode": authCode,
                "firstName": firstName,
                "lastName": lastName
            ]
            
        case .changePassword(let oldPassword, let newPassword):
            return [
                "oldPassword": oldPassword,
                "newPassword": newPassword
            ]
            
        case .reportOffer( _, let type, let comment):
            return [
                "type": type,
                "comment": comment
            ]
            
        case .create(let user, let password):
            return [
                "lastName": user.lastName,
                "firstName": user.firstName,
                "email": user.email,
                "address":
                    [ "city": user.address.city,
                      "country": user.address.country
                    ]
                ,
                "phone": user.phone,
                "password": password
            ]
            
        case .updateUser(let user):
            return [
                "lastName": user.lastName,
                "firstName": user.firstName,
                "address":
                    [ "city": user.address.city,
                      "country": user.address.country
                    ]
                ,
                "phone": user.phone,
            ]
        case .finishTransaction(let coins, let price, let productName):
            return [
                "coins": coins,
                "price": price,
                "productName": productName
            ]
        case .forgotPassword(let email):
            return [ "email": email ]
            
        case .addOffer(let offer):
            return offer.dict
            
        case .editOffer(let offer, _):
            return offer.dict
            
        case .placeBid(let id, let amount, let requiredCoind):
            return [
                "offerId": id,
                "amount": amount,
                "requiredCoins": requiredCoind
            ]
            
        case .changeStatus( _, let requiredCoins):
            return [
                "requiredCoins": requiredCoins
            ]
            
        case .promoteOffer( _, let  expirationDate, let requiredCoins):
            return [
                "requiredCoins": requiredCoins,
                "expirationDate": expirationDate
            ]
            
        case .searchOffers(let search):
            return search.dict
            
        case .searchOffersWithFilter(let search):
            return search.dict
            
        case .startNewChat(let offerId):
            return [
                "offerId": offerId
            ]
            
        case .sendMessage(let message, _):
            return [
                "message": message
            ]
            
        case .saveApnsToken:
            guard let token = Offline.decode(key: .apnsToken, type: String.self) else { return nil }
            return [
                "deviceToken": token
            ]
            
        default :
            return nil
        }
    }
    
    /// Headers for request (if needed)
    var headers: [String: String]? {
        switch self {
        case .login, .create, .getCategories, .loginGoogle, .getCategoriesDetails, .searchPerCategory:
            return nil
        default:
            // set the token if available
            guard let token = Keychain.get(.token) else { return nil }
            return ["Authorization": "Bearer " + token]
        }
    }
    
    // Query items for a endpoint
    var queryItems: [URLQueryItem]? {
        switch self {
        case .resendLink(let email), .checkEmail(let email), .forgotPassword(let email):
            return [
                URLQueryItem(name: "email", value: email)
            ]
        case .getOffers(let page):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "10"),
                URLQueryItem(name: "sort", value: "publishDate,DESC")
            ]
            
        case .searchPerCategory(let text):
            return [
                URLQueryItem(name: "offerTitle", value: text)
            ]
            
        case .getOffersByCategory(let categoryID, let page):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "10"),
                URLQueryItem(name: "categories", value: "\(categoryID)"),
                URLQueryItem(name: "sort", value: "publishDate,DESC")
            ]
            
        case .getOwnerOffers(let email, let page):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "size", value: "10"),
                URLQueryItem(name: "userName", value: email),
                URLQueryItem(name: "sort", value: "publishDate,DESC")
            ]
            
        case .getOffersByIDs(let ids):
            var params: [URLQueryItem] = []
            ids.forEach {
                params.append(URLQueryItem(name: "id", value: "\($0)"))
            }
            return params
            
        case .getOfferBy(_, let increaseView) :
            return [
                URLQueryItem(name: "increaseView", value: "\(increaseView)")
            ]
            
        default:
            return nil
        }
        
    }
    
    /// Create an URLRequest based on the enum properties
    var urlRequest: URLRequest? {
        var host = ""
        var port = 0
        switch self {
        case .getUserChats, .getMessages, .startNewChat, .sendMessage, .loginGoogle, .login, .create, .resendLink, .forgotPassword, .getAllNotifications, .deleteNotification, .getCategoriesDetails, .changePassword, .updateUser, .checkEmail, .getUser, .delete, .saveApnsToken, .logout, .finishTransaction, .reportOffer, .getCurrencies, .loginApple, .getAdds:
            host = ApiRequest.baseURL
            port = 8080
        default: 
            host = ApiRequest.baseURLForOffers
            port = 8082
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.port = port
        urlComponents.host = host
        urlComponents.queryItems = queryItems
        urlComponents.path = path
        
        guard let finalURL = urlComponents.url else { return nil }
        var request = URLRequest(url: finalURL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        request.httpBody = requestBody
        return request
        
    }
}

private extension ApiRequest {
    var requestBody: Data? {
        guard let params = body else { return nil }
        return try? JSONSerialization.data(withJSONObject: params)
    }
}

enum HTTPMethod: String, Codable {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
}
