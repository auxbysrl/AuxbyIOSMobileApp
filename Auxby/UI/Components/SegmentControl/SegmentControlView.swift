//
//  SegmentControlView.swift
//  Auxby
//
//  Created by Eduard Hutu on 27.03.2023.
//

import UIKit

class SegmentControlView: UIView {

    // MARK: - IBOutlets
    @IBOutlet var defaultView: UIView!
    @IBOutlet weak var firstButton: UIButton!
    @IBOutlet weak var secondButton: UIButton!
    
    
    // MARK: Public Propeties
    @IBInspectable var firstTitle: String = "First title" { didSet { firstButton.setTitle(firstTitle.l10n(), for: .normal) }}
    @IBInspectable var secondTitle: String = "Second title" { didSet { secondButton.setTitle(secondTitle.l10n(), for: .normal) }}
    
    var action: ((_ isFirst: Bool) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    func set(firstTitle: String, secondTitle: String, action: ((_ isFirst: Bool) -> Void)?) {
        self.action = action
        firstButton.setTitle(firstTitle, for: .normal)
        secondButton.setTitle(secondTitle, for: .normal)
    }
    
    func setBackground(color: UIColor) {
        defaultView.backgroundColor = color
    }
    
    func setButtons(isFirst: Bool) {
        let firstColor: UIColor = isFirst ? .primaryLight : .white
        let secondColor: UIColor = isFirst ? .white : .primaryLight
        
        firstButton.backgroundColor = firstColor
        secondButton.backgroundColor = secondColor
        firstButton.setTitleColor(secondColor, for: .normal)
        secondButton.setTitleColor(firstColor, for: .normal)
    }

    // MARK: - IBAction
    @IBAction func buttonAction(_ sender: UIButton) {
        let isFirst = sender.accessibilityIdentifier == "1"
        action?(isFirst)
        setButtons(isFirst: isFirst)
    }
}
// MARK: - Private methods
private extension SegmentControlView {
    func setView() {
        Bundle.main.loadNibNamed("SegmentControl", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}

