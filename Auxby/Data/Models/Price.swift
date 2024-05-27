//
//  Price.swift
//  Auxby
//
//  Created by Andrei Traciu on 10.01.2023.
//

import Foundation

enum Currency: String {
    case lei
    case euro
    case dollar
    case unknow
}

struct Price {
    var value: Double
    var currency: Currency
}
