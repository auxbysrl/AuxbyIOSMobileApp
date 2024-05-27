//
//  UIScrollViewExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 30.05.2023.
//

import UIKit

extension UIScrollView {
    func scrollToBottom() {
        let bottomRect = CGRect(x: 0, y: self.contentSize.height - 1, width: 1, height: 1)
        // Scroll to the bottom
        self.scrollRectToVisible(bottomRect, animated: true)
    }
}
