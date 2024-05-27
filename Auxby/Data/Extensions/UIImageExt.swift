//
//  UIImage.swift
//  Auxby
//
//  Created by Andrei Traciu on 11.10.2022.
//

import UIKit

extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        let widthRatio = newSize.width / size.width
        let heightRatio = newSize.height / size.height
        let ratio = widthRatio > heightRatio ? heightRatio : widthRatio
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension UIImageView {
    /**
     Set the image from a remote URL.
     
     An activity indicator will be displayed during the image download.
     */
    func setImage(from url: String, reload: Bool = false, indicatorStyle: UIActivityIndicatorView.Style = .medium, completion: (() -> Void)? = nil) {
        if url.isEmpty { return } // do nothing if the provided string URL is empty
        let indicatorView = getActivityIndicator(style: indicatorStyle)
        addSubview(indicatorView)
        image = nil
        let imageWasDownloaded = ImageDownloader.isDownloaded(imageUrl: url)
        ImageDownloader.get(url, redownload: reload) { imageObj in
            self.subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
            indicatorView.removeFromSuperview()
            let duration = imageWasDownloaded ? 0 : 0.7
            UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
                self.image = imageObj.image
            }, completion: { _ in
                completion?()
            })
        }
    }
}

extension UIButton {
    /**
     Set the image from a remote URL.
     
     An activity indicator will be displayed during the image download.
     */
    func setImage(from url: String, indicatorStyle: UIActivityIndicatorView.Style = .medium, completion: (() -> Void)? = nil) {
        if url.isEmpty { return } // do nothing if the provided string URL is empty
        subviews.filter { $0 is UIActivityIndicatorView }.forEach { $0.removeFromSuperview() }
        let indicatorView = getActivityIndicator(style: indicatorStyle)
        addSubview(indicatorView)
        setImage(nil, for: .normal)
        
        let imageWasDownloaded = ImageDownloader.isDownloaded(imageUrl: url)
        ImageDownloader.get(url) { imageObj in
            indicatorView.removeFromSuperview()
            let duration = imageWasDownloaded ? 0 : 0.7
            UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
                self.setImage(imageObj.image.withRenderingMode(.alwaysOriginal), for: .normal)
                self.imageView?.contentMode = .scaleAspectFill
            }, completion: { _ in
                completion?()
            })
        }
    }
}

private extension UIView {
    /// Create an instance of the UIActivityIndicatorView
    func getActivityIndicator(style: UIActivityIndicatorView.Style = .medium) -> UIActivityIndicatorView {
        let size: CGFloat = 40
        let frame = CGRect(x: frame.width/2-size/2, y: frame.width/2-size/2, width: size, height: size)
        let indicatorView = UIActivityIndicatorView(frame: frame)
        indicatorView.style = style
        indicatorView.startAnimating()
        return indicatorView
    }
}

