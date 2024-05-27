//
//  DateMessageView.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.05.2023.
//

import UIKit

class DateMessageView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var defaultView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    // MARK: Overriden Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setView()
    }
    
    // MARK: - Public properties
    func setCell(date: String) {
        textLabel.text = date
    }
    
}
private extension DateMessageView {
    func setView() {
        Bundle.main.loadNibNamed("DateMessage", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}
