//
//  NotificationCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 04.09.2023.
//

import UIKit

class NotificationCVCell: UICollectionViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    
    var deleteAction: (()-> Void)?
    
    // MARK: - Public Methods
    func setCell(notification: AppNotification) {
        if let notificationType = AppNotificationType(rawValue: notification.type) {
            dateLabel.text = notification.date.convertToCustomDateFormat()
            titleLabel.text = notificationType.title
            textLabel.text = notificationType.description
        }
    }
    
    @IBAction func deleteNotification(_ sender: UIButton) {
        deleteAction?()
    }
}
