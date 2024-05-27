//
//  IBinspectable.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import Foundation
import UIKit

extension UIView {
    /**
     Set view full rounded, a circular view
     - Parameter Bool: set or not
     */
    @IBInspectable var fullRounded: Bool {
        get { true }
        set {
            if newValue {
                layer.cornerRadius = frame.size.height/2
                layer.masksToBounds = true
            }
        }
    }
    
    /**
     Set the corner radius of a UIView from storyboard
     - Parameter CGFloat: number greater than 0
     */
    @IBInspectable var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    /**
     Set the border color to a UIView from storyboard
     - Parameter UIColor: color of border
     */
    @IBInspectable var borderColor: UIColor {
        get { UIColor(cgColor: layer.borderColor!) }
        set { layer.borderColor = newValue.cgColor }
    }
    
    /**
     Set the border width to a UIView from storyboard
     - Parameter CGFloat: number greater than 0
     */
    @IBInspectable var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
}

extension UIImageView {
    /**
     Set the tint color as alwaysTemplate from storyboard
     - Parameter UIColor: tintColor
     */
    @IBInspectable var templateColor: UIColor {
        get { tintColor }
        set {
            tintColor = newValue
            image?.withRenderingMode(.alwaysTemplate)
        }
    }
}

extension UIButton {
    @IBInspectable var imageAspectFit: Bool {
        get { imageView?.contentMode == .scaleAspectFit }
        set { newValue ?
            (imageView?.contentMode = .scaleAspectFit) :
            (imageView?.contentMode = .scaleAspectFill) }
    }
}
