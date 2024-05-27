//
//  UIStackViewExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 21.02.2023.
//

import UIKit

extension UIStackView {
    func removeAllSubviews() {
        self.arrangedSubviews.forEach { $0.removeFromSuperview()}
    }
}
