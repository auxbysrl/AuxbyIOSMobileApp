//
//  ActivityIndicator.swift
//  Auxby
//
//  Created by Eduard Hutu on 14.12.2022.
//

import UIKit
import NVActivityIndicatorView
/**
 Class that handles and display an activity indicator to the screen.
 Indicator is shown immediately after initialization
 */
final class ActivityIndicator {
    
    // MARK: - Private static properties
    private var activityIndicator: NVActivityIndicatorView?
    private var transparentView: UIView?
    private var topMostVC: UIViewController?
    
    /// Shows the indicator after init
    init(vc topController: UIViewController? = topVC()) {
        show(topController)
    }
    
    // MARK: - Public class methods
    /**
     Show activity indicator on the top controller. If the controller is not provided,
     then topController will be retrieved from topVC() method
     */
    private func show(_ topController: UIViewController?) {
        guard let topController = topController else { return }
        for view in topController.view.subviews where view.isKind(of: NVActivityIndicatorView.self) { return }
        
        topMostVC = topController
        let squareSize: CGFloat = 40
        let yOffset = topController.view.frame.size.height/2
        let frame = CGRect(x: topController.view.frame.size.width/2 - squareSize/2, y: yOffset, width: squareSize, height: squareSize)
        activityIndicator = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballSpinFadeLoader, color: .primaryLight)
        topController.view.isUserInteractionEnabled = false
        
        transparentView = topVC().addTransparentView()
        transparentView?.addFadeAnimation(alpha: 0.25)
        
        topController.view.addSubview(activityIndicator!)
        activityIndicator!.startAnimating()
    }
    
    /**
     Remove from superview the previous showed activity indicator,
     and re-enable isUserInteractionEnabled
     */
    func hide() {
        activityIndicator?.stopAnimating()
        activityIndicator?.removeFromSuperview()
        topMostVC?.view.isUserInteractionEnabled = true
        activityIndicator = nil
        transparentView?.addFadeAnimation(alpha: 0, completed: {
            self.transparentView?.removeFromSuperview()
            self.transparentView = nil
        })
    }
}
