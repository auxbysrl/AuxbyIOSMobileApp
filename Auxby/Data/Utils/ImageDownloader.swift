//
//  ImageDownloader.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//

import UIKit
import Combine

struct DownloadedImage {
    private(set) var image: UIImage
    private(set) var path: String
}

final class ImageDownloader {
    
    // MARK: - Public properties
    /// Save into this array all the images already loaded
    private static var loadedImages: [String: UIImage] = [:]
    private static var downloadInProgress: [String: Bool] = [:]
    private static var awaitingCompletions: [[String: ((DownloadedImage) -> Void)]] = []
    
    private static var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Public methods
    /// Download the URL image (if is not already downloaded) and cache it in the local memory
    /// If `redownload` is true, the image will force re-downloaded
    class func get(_ imageUrl: String, redownload: Bool = false, completion: ((_ imageObj: DownloadedImage) -> Void)?) {
        guard let urlString = imageUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let path = urlString.path, let URL = URL(string: urlString) else { return }
        
        if !redownload, let image = loadedImages[path] {
            completion?(DownloadedImage(image: image, path: path))
            return
        }
        
        if !redownload, AppFileManager.fileExist(withPath: path) {
            getImageFromPath(path, completion: { completion?(DownloadedImage(image: $0, path: path)) })
        } else {
            // delete the previous downloaded image with the same name (if exists)
            delete(urlString)
            
            if downloadInProgress[urlString] ?? false == false {
                downloadInProgress[urlString] = true
                URLSession.shared
                    .downloadTaskPublisher(for: URL)
                    .sink { completion in
                        downloadInProgress[urlString] = false
                        if case .failure(let err) = completion {
                            print(err.localizedDescription.consoleError)
                        }
                    } receiveValue: { (url, response) in
                        let statusCode = (response as? HTTPURLResponse)?.statusCode
                        // valid statusCode range is between 200 and 299
                        if let code = statusCode, (200...299 ~= code),
                           let image = UIImage(contentsOfFile: url.path) {
                            runOnMainThread {
                                // call all the waiting completions
                                let imgObj = DownloadedImage(image: image, path: path)
                                let allWaitingCompletions = awaitingCompletions.filter { $0.keys.contains(where: { $0 == urlString })}
                                allWaitingCompletions.forEach { $0[urlString]?(imgObj) }
                                completion?(imgObj)
                            }
                            // remove the waiting completions from the array
                            awaitingCompletions.removeAll(where: { $0[urlString] != nil })
                        } else {
                            delete(urlString)
                            print("Cannot download the image from the URL: \n\(urlString) \nError code: \(statusCode ?? -1)".consoleError)
                        }
                    }.store(in: &cancellables)
            } else {
                if let callback = completion {
                    awaitingCompletions.append([urlString: callback])
                }
            }
        }
    }
    
    class func delete(_ imageUrl: String) {
        guard let path = imageUrl.path else { return }
        loadedImages[path] = nil
        if AppFileManager.fileExist(withPath: path) {
            AppFileManager.removeFile(withName: path)
        }
    }
    
    class func isDownloaded(imageUrl: String) -> Bool {
        guard let path = imageUrl.path else { return false }
        return AppFileManager.fileExist(withPath: path)
    }
    
    /// Get image from the local store (from the cache)
    private class func getImageFromPath(_ path: String, completion: ((UIImage) -> Void)?) {
        DispatchQueue.global(qos: .userInteractive).async {
            let url = URL(fileURLWithPath: AppFileManager.path(name: path))
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                runOnMainThread {
                    self.loadedImages[path] = image
                    completion?(image)
                }
            }
        }
    }
}

private extension String {
    /// Used when download & save a file
    var path: String? {
        components(separatedBy: "/").last
    }
}
