//
//  UIAlert.swift
//  Auxby
//
//  Created by Eduard Hutu on 24.10.2022.
//

import UIKit
import L10n_swift

final class UIAlert {
    
    struct Option {
        var title: String
        var action: (() -> Void)?
        var style: UIAlertAction.Style = .default
    }

    /// Show an UIAlertController with an single confirmation button
    class func showOneButton(vc: UIViewController = topVC(), title: String? = nil, message: String,
                             butttonTitle: String = "Ok", buttonAction: (() -> Void)? = nil) {
        // return if the title and message are not set or another UIAlertController is already presented
        if (title == nil && message.isEmpty) || topVC() is UIAlertController { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: butttonTitle, style: .destructive, handler: { _ in buttonAction?() }))
        alert.setAppearance()
        let mesage = alert.message!
        let attributedString = NSAttributedString(
            string: mesage ,
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.primaryDark]
        )
        alert.setValue(attributedString, forKey: "attributedMessage")
        
        vc.present(alert, animated: true)
    }
    
    /// Show an UIAlertController with two buttons, left the cancel in blue, right the action in red
    class func showTwoButtons(vc: UIViewController = topVC(), title: String? = nil, message: String,
                              cancelTitle: String = "Cancel", confirmTitle: String,
                              confirmActionCompletion: @escaping (() -> Void), cancelActionCompletion: (() -> Void)? = nil) {
        
        // return if the title and message are not set or another UIAlertController is already presented
        if title == nil, message.isEmpty || topVC() is UIAlertController { return }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .default, handler: { _ in
            cancelActionCompletion?()
        }))
        alert.addAction(UIAlertAction(title: confirmTitle, style: .destructive, handler: { _ in
            confirmActionCompletion()
        }))
        alert.setAppearance()
        vc.present(alert, animated: true)
    }
    
    /// Show an UIAlertController with the provided actions
    class func showActionSheet(vc: UIViewController = topVC(),
                               options: [Option],
                               appeared: (() -> Void)? = nil,
                               iPadSourceView: UIView) {
        // return if the options array is not set or another UIAlertController is already presented
        if options.isEmpty || topVC() is UIAlertController { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for option in options {
            let action = UIAlertAction(title: option.title, style: option.style, handler: { _ in
                option.action?()
            })
            if option.style != .destructive {
                action.setValue(UIColor.primaryLight, forKey: "titleTextColor")
            }
            alert.addAction(action)
        }
        alert.setAppearance()
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.popoverPresentationController?.sourceView = iPadSourceView
        vc.present(alert, animated: true, completion: appeared)
    }
    
    /// Show An UIAlertController with an Text Field input type
    class func showInputText(vc: UIViewController = topVC(),
                             title: String,
                             message: String,
                             isPassword: Bool = true,
                             confirmationAction: @escaping ((_ text: String?) -> Void),
                             cancelAction: @escaping (() -> Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = isPassword ? "password".l10n() : "optional".l10n()
            textField.isSecureTextEntry = isPassword
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in cancelAction() }))
        let submitAction = UIAlertAction(title: isPassword ? "delete".l10n() : "save".l10n(), style: .destructive) { _ in
            let text = alert.textFields?[0].text
            confirmationAction(text)
        }
        
        alert.addAction(submitAction)
        vc.present(alert, animated: true)
    }
}

extension UIAlertController {
    func setAppearance() {
        view.tintColor = .white
        if let bgView = view.subviews.first,
           let groupView = bgView.subviews.first,
           let contentView = groupView.subviews.first {
            contentView.backgroundColor = .background
        }
    }
}
