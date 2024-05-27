//
//  Network.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import Network
import Combine
import UIKit
import GoogleSignIn

final class Network {

    // Single instance
    static let shared = Network()
    let signInConfig = GIDConfiguration(clientID: "156615882044-mk6ccisj7h3k7v0rtogpn8q2i40rbppu.apps.googleusercontent.com" )
    var isConnected = true

    // MARK: - Private properties
    private let urlSession: URLSession
    private let networkMonitor = NWPathMonitor()

    // disable outside initialization
    private init() {
        let session: URLSession = {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 30
            return URLSession(configuration: config)
        }()
        urlSession = session
        
        // Observe network connection and changes
        networkMonitor.pathUpdateHandler = { [unowned self] path in
            isConnected = path.status == .satisfied
        }
        networkMonitor.start(queue: .global(qos: .background))
    }

    // MARK: - Public methods
    func request<T: Decodable>(endpoint: ApiRequest, type: T.Type) -> AnyPublisher<RequestState<T>, Never> {
        request(endpoint: endpoint)
    }
    
    func voidRequest(endpoint: ApiRequest) -> AnyPublisher<RequestState<Void>, Never> {
        guard let urlRequest = endpoint.urlRequest else {
            let error = NetworkError.invalidRequest("Invalid request URL")
            return AnyPublisher(Just(.failed(error)))
        }
        // print the request body parameters if they are added to the request
        if let dataBody = urlRequest.httpBody, let prettyJson = dataBody.asJsonPrettyPrinted {
            print("\n\(prettyJson)".consoleParameters)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        // Convert snake-case keys to camel-case keys by default
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        // A text description in the console for easy debugging
        let description = "\(endpoint.method.rawValue.uppercased()): \(urlRequest.url?.absoluteString ?? "")"
        
        return urlSession
            .dataTaskPublisher(for: urlRequest)
        // Map on Request response
            .tryMap({ data, response in
                // try to extract the readable text data as string, from the received data
                let textData = data.asJsonPrettyPrinted ?? String(data: data, encoding: .utf8)
                // If the response is invalid, throw an error
                if let response = response as? HTTPURLResponse,
                   // valid statusCode range is between 200 and 299
                   !(200...299 ~= response.statusCode) {
                    // print the response textData received on failure response
                    if let err = textData { print("\nCode \(response.statusCode)\n\(description)\n\n\(err)".consoleAPIError) }
                    let errorMsg = textData?.asDictionary?["message"] as? String ?? textData
                    if response.statusCode == 401 {
                        Offline.delete(key: .currentUser)
                        Keychain.deleteAll()
                        Offline.delete(key: .offers)
                        Offline.delete(key: .favorites)
                        Offline.delete(key: .userOffers)
                        runOnMainThread {
                            NotifyCenter.post(.noUser)
                            if topVC().isModal {
                                topVC().dismissVC {
                                    topVC().pushVC(LoginVC.asVC())
                                }
                            } else {
                                topVC().pushVC(LoginVC.asVC())
                            }
                            
                        }
                    }
                    throw self.httpError(response.statusCode, errorDescription: errorMsg)
                }
                // print the response textData received on success response
                if let response = textData { print("\n\(description)\n\n\(response)".consoleSuccessResponse) }
                // Return Success Response data
            })
            .receive(on: RunLoop.main)
        // expose our publisher
            .convertToLoadingState()
    }
    
    func request<T: Decodable>(endpoint: ApiRequest) -> AnyPublisher<RequestState<T>, Never> {
        guard let urlRequest = endpoint.urlRequest else {
            let error = NetworkError.invalidRequest("Invalid request URL")
            return AnyPublisher(Just(.failed(error)))
        }
        // print the request body parameters if they are added to the request
        if let dataBody = urlRequest.httpBody, let prettyJson = dataBody.asJsonPrettyPrinted {
            print("\n\(prettyJson)".consoleParameters)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        // Convert snake-case keys to camel-case keys by default
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        // A text description in the console for easy debugging
        let description = "\(endpoint.method.rawValue.uppercased()): \(urlRequest.url?.absoluteString ?? "")"
        
        return urlSession
            .dataTaskPublisher(for: urlRequest)
            // Map on Request response
            .tryMap({ data, response in
                // try to extract the readable text data as string, from the received data
                let textData = data.asJsonPrettyPrinted ?? String(data: data, encoding: .utf8)
                // If the response is invalid, throw an error
                if let response = response as? HTTPURLResponse,
                   // valid statusCode range is between 200 and 299
                   !(200...299 ~= response.statusCode) {
                    // print the response textData received on failure response
                    if let err = textData { print("\nCode \(response.statusCode)\n\(description)\n\n\(err)".consoleAPIError) }
                    let errorMsg = textData?.asDictionary?["message"] as? String ?? textData
                    if response.statusCode == 403 {
                        Offline.delete(key: .currentUser)
                        Keychain.deleteAll()
                        Offline.delete(key: .offers)
                        Offline.delete(key: .favorites)
                        Offline.delete(key: .userOffers)
                        runOnMainThread {
                            NotifyCenter.post(.noUser)
                            if topVC().isModal {
                                topVC().dismissVC { 
                                    topVC().pushVC(LoginVC.asVC())
                                }
                            } else {
                                topVC().pushVC(LoginVC.asVC())
                            }
                            
                        }
                    }
                    throw self.httpError(response.statusCode, errorDescription: errorMsg)
                }
                // print the response textData received on success response
                if let response = textData { print("\n\(description)\n\n\(response)".consoleSuccessResponse) }
                // Return Success Response data
                return data
            })
            .decode(type: T.self, decoder: decoder)
            // map the received error (if any) to the local NetworkError type
            .mapError { self.mapError($0, type: T.self, desc: description) }
            // return the response on the Main Thread
            .receive(on: RunLoop.main)
            // expose our publisher
            .convertToLoadingState()
    }
}

extension Network {
    /// Parses a HTTP StatusCode and returns a proper error
    /// - Parameter statusCode: HTTP status code
    /// - Returns: Mapped Error
    private func httpError(_ statusCode: Int, errorDescription: String?) -> NetworkError {
        switch statusCode {
        case 400: return .badRequest(statusCode, errorDescription)
        case 401: return .unauthorized(statusCode, errorDescription)
        case 403: return .forbidden(statusCode, errorDescription)
        case 404: return .notFound(statusCode, errorDescription)
        case 402, 405...499: return .error4xx(statusCode, errorDescription)
        case 500: return .serverError(statusCode, errorDescription)
        case 501...599: return .error5xx(statusCode, errorDescription)
        default: return .unknownError(errorDescription)
        }
    }

    /// Parses URLSession Publisher errors and return proper ones
    /// - Parameter error: URLSession publisher error
    /// - Returns: Readable NetworkRequestError
    private func mapError<T>(_ err: Error, type: T.Type, desc: String) -> NetworkError {
        let error: NetworkError
        switch err {
        case let err as NetworkError:
            error = err
        case let err as DecodingError:
            error = .decodingError("\nError decoding: \(T.self) \n\n\(err)")
        case let urlError as URLError:
            let code = urlError.code.rawValue
            if code == -1020 || code == -1009 { // means no internet connection available
                error = .noInternetConnection("No internet connection available")
            } else if code == -2102 || code == -1001 {
                error = .timeOut("The request timed out.")
            } else if code == -1 {
                error = .invalidRequest("Invalid request URL")
            } else {
                error = .urlSessionFailed(urlError, urlError.localizedDescription)
            }
        default:
            error = .unknownError("\(err)")
        }
        // print the error on the terminal for easy troubleshooting
        print("\n\(desc)\n\(error.localizedDescription)".consoleError)
        return error
    }
}

enum NetworkError: LocalizedError, Equatable {
    case invalidRequest(_ errorDescription: String?)
    case badRequest(_ code: Int,_ errorDescription: String?)
    case unauthorized(_ code: Int, _ errorDescription: String?)
    case forbidden(_ code: Int,_ errorDescription: String?)
    case notFound(_ code: Int,_ errorDescription: String?)
    case error4xx(_ code: Int, _ errorDescription: String?)
    case serverError(_ code: Int,_ errorDescription: String?)
    case error5xx(_ code: Int, _ errorDescription: String?)
    case decodingError(_ errorDescription: String?)
    case urlSessionFailed(_ error: URLError, _ errorDescription: String?)
    case unknownError(_ errorDescription: String?)
    case customError(_ code: Int,_ errorDescription: String?)
    case noInternetConnection(_ errorDescription: String?)
    case timeOut(_ errorDescription: String?)
    var errorDescription: String? {
        switch self {
        case
                .forbidden(_, let err), .notFound(_, let err), .error4xx(_, let err),
                .invalidRequest(let err), .badRequest(_, let err), .unauthorized(_, let err),
                .serverError(_, let err), .error5xx(_, let err), .decodingError(let err),
                .urlSessionFailed(_, let err), .unknownError(let err),
                .customError(_, let err), .noInternetConnection(let err),
                .timeOut(let err):
            return err
        }
    }
    
    var errorStatus: Int? {
        switch self {
        case .error4xx(let status, _), .error5xx(let status, _), .unauthorized(let status, _),
                .forbidden(let status, _), .notFound(let status, _), .badRequest(let status, _),
                .serverError(let status, _), .customError(let status, _):
            return status
        default:
            return nil
        }
    }
}

extension Error {
    var noInternetOrTimeout: Bool {
        guard let err = self as? NetworkError else {
            return false
        }
        if case NetworkError.noInternetConnection = err {
            return true
        } else if case NetworkError.timeOut = err {
            return true
        }
        return false
    }
    
    var errorStatus: Int? {
        guard let err = self as? NetworkError else {
            return nil
        }
        return err.errorStatus
    }
}
