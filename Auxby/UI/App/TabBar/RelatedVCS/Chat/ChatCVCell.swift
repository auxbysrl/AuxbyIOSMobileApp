//
//  ChatCVCell.swift
//  Auxby
//
//  Created by Eduard Hutu on 12.07.2023.
//

import UIKit

class ChatCVCell: UICollectionViewCell {
    @IBOutlet weak var offerImage: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var offerTitle: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setCell(chat: CompleteChat) {
        var isNewMessage = true
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "ro_RO")
        guard let givenDate = dateFormatter.date(from: chat.chat.lastMessageTime) else {
            fatalError("Invalid date format")
        }
        if chat.readDate != nil {
            if givenDate <= chat.readDate! {
                isNewMessage = false
            }
        }
        if let currentUser = Offline.currentUser {
            if chat.chat.guest == "\(currentUser.firstName) \(currentUser.lastName)" {
                ownerName.text = chat.chat.host
            } else {
                ownerName.text = chat.chat.guest
            }
            offerTitle.font = isNewMessage ?  UIFont(name: "Montserrat-Bold", size: 14) : UIFont(name: "Montserrat-Medium", size: 14)
            offerTitle.text = chat.chat.roomName
            dateFormatter.dateFormat = "dd.MM"
            let formattedDateString = dateFormatter.string(from: givenDate)
            dateLabel.text = formattedDateString
            offerImage.setImage(from: chat.chat.chatImage)
        }
    }
}
