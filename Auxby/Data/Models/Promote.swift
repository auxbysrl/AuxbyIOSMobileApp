//
//  Promote.swift
//  Auxby
//
//  Created by Eduard Hutu on 16.05.2023.
//

import Foundation

class Promote {
    var days: Int
    var price: Int 
    
    init(days: Int, price: Int) {
        self.days = days
        self.price = price
    }
    
    func getExpirationDate() -> String {
        let now = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: self.days, to: now)!
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let futureDateString = formatter.string(from: futureDate)
        return futureDateString
    }
}
