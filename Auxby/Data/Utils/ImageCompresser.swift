//
//  ImageCompresser.swift
//  Auxby
//
//  Created by Eduard Hutu on 21.06.2024.
//

import UIKit
class ImageCompresser {
    func compressImage(_ image: UIImage, maxWidth: CGFloat = 800, maxHeight: CGFloat = 800, compressionQuality: CGFloat = 0.4) -> Data? {
        // Ensure the compression quality is between 0 and 1
        let clampedQuality = max(0, min(compressionQuality, 1))
        
        // Scale the image
        let scaledSize = calculateScaledSize(for: image.size, maxWidth: maxWidth, maxHeight: maxHeight)
        let scaledImage = resizeImage(image, to: scaledSize)
        
        // Compress the image to JPEG format
        return scaledImage.jpegData(compressionQuality: clampedQuality)
    }

    func calculateScaledSize(for originalSize: CGSize, maxWidth: CGFloat, maxHeight: CGFloat) -> CGSize {
        let widthRatio = maxWidth / originalSize.width
        let heightRatio = maxHeight / originalSize.height
        let scaleRatio = min(widthRatio, heightRatio)
        return CGSize(width: originalSize.width * scaleRatio, height: originalSize.height * scaleRatio)
    }

    func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? image
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
