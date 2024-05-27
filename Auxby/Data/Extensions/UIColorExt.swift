//
//  UIColorExt.swift
//  Auxby
//
//  Created by Eduard Hutu on 17.10.2022.
//

import Foundation
import UIKit

extension UIColor {
    
    static let red = UIColor(named: "red")!
    static let black = UIColor(named: "black")!
    static let white = UIColor(named: "white")!
    static let green = UIColor(named: "green")!
    static let textDark = UIColor(named: "textDark")!
    static let textLight = UIColor(named: "textLight")!
    static let secondary = UIColor(named: "secondary")!
    static let background = UIColor(named: "background")!
    static let primaryDark = UIColor(named: "primaryDark")!
    static let primaryLight = UIColor(named: "primaryLight")!

    static var random: UIColor {
        UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 0.5
        )
    }
}

extension UIColor {
    convenience init(hex: String) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 1
        
        let hexColor = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            if hexColor.count == 8 {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
            } else if hexColor.count == 6 {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
            }
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return (NSString(format: "#%06x", rgb) as String).uppercased()
    }
}
