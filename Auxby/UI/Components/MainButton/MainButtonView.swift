//
//  MainButton.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import UIKit
import TransitionButton
import L10n_swift

class MainButtonView: UIView {

    // MARK: - IBOutlets
    @IBOutlet private var defaultView: UIView!
    @IBOutlet var button: TransitionButton!

    // MARK: - Public properties
    @IBInspectable var title: String = "save".l10n() { didSet { button.setTitle(title, for: .normal) }}
    @IBInspectable var isActive: Bool = false { didSet { setButtonActive(isActive) }}
    var action: (() -> Void)?
    
    // MARK: - Properties
    var animationInProgress = false
    private var animDuration: Double = 0.3
    private var startAnimationExecuted = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }

    // MARK: - IBActions
    @IBAction private func buttonAction(_ sender: UIButton) {
        action?()
    }

    // MARK: - Public methods
    func set(title: String, action: @escaping (() -> Void)) {
        button.setTitle(title, for: .normal)
        self.action = action
    }

    /// Start animating the button, before starting a task, exemple: before a network call.
    func startAnimation() {
        animationInProgress = true
        startAnimationExecuted = true
        button.startAnimation()
    }
    
    /**
     Stop animating the button.
     - Parameter animationStyle: the style of the stop animation
     */
    func stopAnimation(animationStyle: StopAnimationStyle = .normal, completion: (() -> Void)? = nil) {
        guard animationInProgress else { return }
        // TransitionButton does not work properly if stopAnimation is executed before startAnimation
        if !startAnimationExecuted { startAnimation() }
        // if the startAnimation was not executed, wait until the startAnimation() is executed
        delay(animDuration) {
            self.button.stopAnimation(animationStyle: animationStyle, revertAfterDelay: 0, completion: completion)
            self.animationInProgress = false
        }
    }
}

// MARK: - Private methods
private extension MainButtonView {
    func setView() {
        Bundle.main.loadNibNamed("MainButton", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
    
    func setButtonActive(_ active: Bool) {
        button.isUserInteractionEnabled = active
        let color : UIColor = active ? .primaryLight : .primaryLight.withAlphaComponent(0.5)
        button.setTitleColor(active ? .white : .white, for: .normal)
        button.backgroundColor = color
    }
}
