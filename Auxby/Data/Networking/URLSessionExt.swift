//
//  URLSessionExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 07.11.2022.
//


import Combine
import UIKit

extension URLSession {
    
    func downloadTaskPublisher(for url: URL) -> URLSession.DownloadTaskPublisher {
        downloadTaskPublisher(for: .init(url: url))
    }
    
    func downloadTaskPublisher(for request: URLRequest) -> URLSession.DownloadTaskPublisher {
        .init(request: request, session: self)
    }
    
    struct DownloadTaskPublisher: Publisher {
        
        typealias Output = (url: URL, response: URLResponse)
        typealias Failure = URLError
        
        let request: URLRequest
        let session: URLSession
        
        init(request: URLRequest, session: URLSession) {
            self.request = request
            self.session = session
        }
        
        func receive<S>(subscriber: S) where S: Subscriber,
             DownloadTaskPublisher.Failure == S.Failure,
             DownloadTaskPublisher.Output == S.Input {
                 let subscription = DownloadTaskSubscription(subscriber: subscriber, session: self.session, request: self.request)
                 subscriber.receive(subscription: subscription)
             }
    }
}

extension URLSession {
    
    final class DownloadTaskSubscription<SubscriberType: Subscriber>: Subscription where
    SubscriberType.Input == (url: URL, response: URLResponse),
    SubscriberType.Failure == URLError {
        
        private var subscriber: SubscriberType?
        private weak var session: URLSession!
        private var request: URLRequest!
        private var task: URLSessionDownloadTask!
        
        init(subscriber: SubscriberType, session: URLSession, request: URLRequest) {
            self.subscriber = subscriber
            self.session = session
            self.request = request
        }
        
        func request(_ demand: Subscribers.Demand) {
            guard demand > 0 else { return }
            task = session.downloadTask(with: request) { [weak self] url, response, error in
                if let error = error as? URLError {
                    self?.subscriber?.receive(completion: .failure(error))
                    return
                }
                guard let response = response else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badServerResponse)))
                    return
                }
                guard let url = url else {
                    self?.subscriber?.receive(completion: .failure(URLError(.badURL)))
                    return
                }
                do {
                    // cache the image into the documentDirectory
                    let cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let imageNameIdentifier = self?.request.url?.absoluteString.components(separatedBy: "/").last ?? "someImage"
                    let fileUrl = cacheDir.appendingPathComponent(imageNameIdentifier)
                    try FileManager.default.moveItem(atPath: url.path, toPath: fileUrl.path)
                    
                    _ = self?.subscriber?.receive((url: fileUrl, response: response))
                    self?.subscriber?.receive(completion: .finished)
                } catch {
                    self?.subscriber?.receive(completion: .failure(URLError(.cannotCreateFile)))
                }
            }
            task.resume()
        }
        
        func cancel() {
            task.cancel()
        }
    }
}
