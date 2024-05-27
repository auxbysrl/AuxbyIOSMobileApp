//
//  RecivedMessageView.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.05.2023.
//

import UIKit

class RecivedMessageView: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var defaultView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
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
    func setCell(message: Message) {
        textLabel.text = message.messageText
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ro_RO")
        guard let givenDate = dateFormatter.date(from: message.messageTime) else {
            fatalError("Invalid date format")
        }
        dateFormatter.dateFormat = "HH:mm"
        let formattedDateString = dateFormatter.string(from: givenDate)
        timeLabel.text = formattedDateString
    }
    
}
private extension RecivedMessageView {
    func setView() {
        Bundle.main.loadNibNamed("RecivedMessage", owner: self, options: nil)
        defaultView.fitXibView(inside: self)
    }
}

