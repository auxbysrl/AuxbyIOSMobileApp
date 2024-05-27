//
//  profileVM.swift
//  Auxby
//
//  Created by Eduard Hutu on 02.12.2022.
//

import UIKit
import Combine
import L10n_swift

class ProfileVM {
    var isEditing = false
    var lastTag = 0
    var user: User = User()
    @Published private(set) var getUserState = RequestState<User>.idle
    @Published private(set) var updateUserState = RequestState<User>.idle
    @Published private(set) var getDeleteUser = RequestState<Void>.idle
    @Published private(set) var getLogoutState = RequestState<Void>.idle
    var cancellables: Set<AnyCancellable> = []
    var startAddingImage: (()->Void)?
    var finishAddingImage: (()->Void)?
    
    init() {
        if let user = Offline.decode(key: .currentUser, type: User.self) {
            self.user = user
        }
        getUser()
    }
    
    func getUser() {
        getUserState = .loading
        Network.shared.request(endpoint: .getUser)
            .assign(to: &$getUserState)
    }
    
    func updateUser() {
        updateUserState = .loading
        Network.shared.request(endpoint: .updateUser(user: user))
            .assign(to: &$updateUserState)
    }
    
    func deleteUser() {
        getDeleteUser = .loading
        Network.shared.voidRequest(endpoint: .delete)
            .assign(to: &$getDeleteUser)
    }
    
    func logout() {
        getLogoutState = .loading
        Network.shared.voidRequest(endpoint: .logout)
            .assign(to: &$getLogoutState)
    }
    
    func updateUserImage(photo: UIImage) {
        runOnMainThread { [unowned self] in
            startAddingImage?()
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        if ApiRequest.isProduction {
            urlComponents.port = 8080
        }
        urlComponents.host = ApiRequest.baseURL
        urlComponents.path = "/api/v1/user/avatar"
        let finalURL = urlComponents.url ??   URL(string: "https://auxby.ro:8080/api/v1/user/avatar")!
        var request = URLRequest(url: finalURL)
        request.httpMethod = "POST"
        // Set the content type to multipart/form-data and set the boundary
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let token = Keychain.get(.token)
        request.addValue("Bearer \(token ?? "")", forHTTPHeaderField: "Authorization")
        
        // Create a data object to hold the body of the request
        var body = Data()
        
        // Append the image data to the body
        if let imageData = compressImage(photo, maxFileSize: 6 * 1024 * 1024) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Close the request body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Set the request body
        request.httpBody = body
        
        // Create a URLSession and a data task to send the request
        let session = URLSession.shared
        let task = session.dataTask(with: request) { [unowned self] data, response, error in
            if let error = error {
                print("Error sending request: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            if httpResponse.statusCode == 200 {
               
                runOnMainThread { [unowned self] in
                    finishAddingImage?()
                    Offline.encode(true, key: .shouldReloadProfilePicture)
                    getUser()
                }
            } else {
                UIAlert.showOneButton(message: "errorImages".l10n()) {
                    self.finishAddingImage?()
                }
            }
            
        }
        task.resume()
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
