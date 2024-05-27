//
//  ImmagePicker.swift
//  Auxby
//
//  Created by Eduard Hutu on 13.12.2022.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

/**
 Get a image from gallery or camera using selectedImage() closure
 */
final class ImagePicker: UIImagePickerController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Public Properties
    var presentationStyle: UIModalPresentationStyle = .pageSheet
    var selectedImage: ((_ image: UIImage) -> Void)?
    var viewAppeared: (() -> Void)?
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        allowsEditing = true
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        mediaTypes = [UTType.image.identifier]
        modalPresentationStyle = presentationStyle
        if sourceType == .camera {
            stopVideoCapture()
            cameraCaptureMode = .photo
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var chosenImage = info[.originalImage] as! UIImage
        if let croppedImage = info[.editedImage] as? UIImage {
            chosenImage = croppedImage
        }
        selectedImage?(chosenImage)
        dismissVC()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismissVC()
    }
    
    /// This function shows actions alert for image picker.
    // - Parameter viewController: View Controller on which to present
    func show(_ vc: UIViewController, iPadSourceView: UIView) {
        if isPad {
            modalPresentationStyle = .popover
            popoverPresentationController?.sourceView = iPadSourceView
        }
        UIAlert.showActionSheet(options: [
            UIAlert.Option(title: "Take photo", action: {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.sourceType = .camera
                    vc.presentVC(self)
                } else {
                    UIAlert.showOneButton(message: "Camera not available on this device.")
                }
            }),
            UIAlert.Option(title: "Choose from photos", action: {
                self.sourceType = .photoLibrary
                self.modalTransitionStyle = .crossDissolve
                vc.presentVC(self)
            })
        ], appeared: {
            self.viewAppeared?()
        }, iPadSourceView: iPadSourceView)
    }
}
