//
//  UIViewControllerExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import UIKit
import SafariServices

extension UIViewController {
    /// Check if the controller is pushed by navigation controller or presented
    var isModal: Bool {
        if let index = navigationController?.viewControllers.firstIndex(of: self), index > 0 {
            return false
        } else if presentingViewController != nil {
            return true
        } else if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        } else if tabBarController?.presentingViewController is UITabBarController {
            return true
        } else {
            return false
        }
    }
    
    /// Check if the controller has a navigation controller and get its visible view controller; otherwise return itself
    var contentVC: UIViewController {
        (self as? UINavigationController)?.visibleViewController ?? self
    }
    
    /// Check in the first controller of navigation controller if exists; otherwise return contentVC
    var rootVC: UIViewController {
        (self as? UINavigationController)?.viewControllers.first ?? contentVC
    }
    
    /// Pushes a view controller onto the receiver’s stack and updates the display.
    func pushVC(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Pops the top view controller from the navigation stack and updates the display.
    func popVC() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /// Pops the top view controller from the navigation stack and updates the display.
    /// You can specifiry how many poops 😅 the navigation controller should do
    func popVC(_ count: Int = 1) {
        if count == 1 {
            _ = navigationController?.popViewController(animated: true)
        } else {
            guard let vcs = navigationController?.viewControllers, vcs.count > count else {
                print("The navigationController does not have in stack \(count) viewControllers")
                return
            }
            navigationController?.popToViewController(vcs[vcs.count-count-1], animated: true)
        }
    }
    
    /// Presents a view controller modally.
    func presentVC(_ vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
    
    /// Dismisses the view controller that was presented modally by the view controller.
    func dismissVC(completion: (() -> Void)? = nil) {
        dismiss(animated: true, completion: completion)
    }
    
    /// Add a child view controller to a parent view
    func addChildVC(_ vc: UIViewController, toView view: UIView) {
        addChild(vc)
        vc.view.frame = view.bounds
        view.addSubview(vc.view)
        vc.didMove(toParent: self)
    }
    
    /// Remove a child view controller from superview
    func removeChildVC() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    /// Add a transparent view to a entire view of a UIViewController,
    /// then you can set its properties like backgroundColor, alpha, etc.
    func addTransparentView(vc: UIViewController = topVC(), to view: UIView = topVC().view) -> UIView {
        let transparentView = UIView(frame: vc.view.frame)
        transparentView.backgroundColor = .black
        transparentView.alpha = 0
        vc.view.addSubview(transparentView)
        return transparentView
    }
    
    /// Open an instance of the SFSafariViewController with the provided URL address
    func presentSFSafariVC(url: String) {
        guard let URL = URL(string: url) else {
            print("Invalid URL")
            return
        }
        let safariVC = SFSafariViewController(url: URL)
        safariVC.modalPresentationStyle = .automatic
        safariVC.preferredControlTintColor = .white
        safariVC.preferredBarTintColor = .background
        presentVC(safariVC)
    }
    
    func hideKeyboardWhenTappedAround() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
        }
}
