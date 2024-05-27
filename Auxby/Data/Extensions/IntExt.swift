//
//  IntExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.03.2023.
//

import Foundation

extension Int {
    var formattedString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 3
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
