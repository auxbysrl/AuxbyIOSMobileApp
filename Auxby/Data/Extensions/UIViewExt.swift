//
//  UIViewExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import UIKit

extension UIView {
    
    /// Set top, bottom, leading, trailing constraint constant to 0
    func fitXibView(inside container: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        frame = container.frame
        container.addSubview(self)
        
        func setAttribute(_ attr: NSLayoutConstraint.Attribute) {
            NSLayoutConstraint(
                item: self,
                attribute: attr,
                relatedBy: .equal,
                toItem: container,
                attribute: attr,
                multiplier: 1.0,
                constant: 0
            ).isActive = true
        }
        
        setAttribute(.top)
        setAttribute(.bottom)
        setAttribute(.leading)
        setAttribute(.trailing)
    }
    
    /// Add bottom shadow to a UIView
    func addBottomShadow(height: CGFloat = 7, color: UIColor = .black) {
        layer.shadowOffset = CGSize(width: 0, height: height)
        layer.shadowColor = color.cgColor
        layer.shadowRadius = height
        layer.shadowOpacity = 1
    }
    
    /**
     Set a view bottom constraint to top of the keyboard layout
     
     IMPORTANT: When call this method for a view, ensure that the bottom
     constraint priority of the view is lower that 1000
     */
    func setBottomConstraintToTopOfKeyboard() {
        if isRunningOnMac { return }
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(lessThanOrEqualTo: keyboardLayoutGuide.topAnchor)
        ])
    }
    
    /// Animate the view alpha with fade effect
    func addFadeAnimation(duration: Double = 0.2, alpha a: CGFloat, completed: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration, delay: 0, options: [.curveLinear], animations: {
            self.alpha = a
            self.layoutIfNeeded()
        }, completion: { _ in completed?() })
    }
    
    /// Animate transition between two states
    func animateTransition(_ duration: TimeInterval = 0.25, completion: (() -> Void)? = nil, animation: @escaping (() -> Void)) {
        UIView.transition(with: self, duration: duration, options: .transitionCrossDissolve, animations: {
            animation()
        }, completion: { _ in completion?() })
    }
    
    func shake() {
           let animation = CABasicAnimation(keyPath: "position")
           animation.duration = 0.07
           animation.repeatCount = 5
           animation.autoreverses = true
           animation.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
           animation.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
           layer.add(animation, forKey: "position")
       }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func dropShadow(scale: Bool = true) {
       layer.masksToBounds = false
       layer.shadowColor = UIColor.black.cgColor
       layer.shadowOpacity = 0.2
       layer.shadowOffset = CGSize(width: -0.2, height: 0.1)
       layer.shadowRadius = 8

       layer.shadowPath = UIBezierPath(rect: bounds).cgPath
       layer.shouldRasterize = true
       layer.rasterizationScale = scale ? UIScreen.main.scale : 1
     }
    
    /// The view controller that is responsible for a particular view
    func findParentVC() -> UIViewController? {
        if let nextResponder = next as? UIViewController {
            return nextResponder
        } else if let nextResponder = next as? UIView {
            return nextResponder.findParentVC()
        } else {
            return nil
        }
    }
    
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension UILabel {
    var numberOfVisibleLines: Int {
        let textSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let height = Int(sizeThatFits(textSize).height)
        let lineHeight = Int(font.lineHeight)
        return height / lineHeight
    }
}
