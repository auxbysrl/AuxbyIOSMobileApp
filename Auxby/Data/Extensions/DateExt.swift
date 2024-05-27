//
//  DateExt.swift
//  NDSports
//
//  Created by Senocico Stelian on 14.03.2022.
//

import Foundation

extension Date {
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        // use UTC 0 time zone
        //formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }

    func diffInDays(_ fromDate: Date, absoluteValue: Bool = true) -> Int {
        let days = (Calendar.current as NSCalendar).components(.day, from: self, to: fromDate, options: []).day
        return absoluteValue ? abs(days!) : days!
    }
    
    func diffInHours(_ fromDate: Date, absoluteValue: Bool = true) -> Int {
        let hours = (Calendar.current as NSCalendar).components(.hour, from: self, to: fromDate, options: []).hour
        return absoluteValue ? abs(hours!) : hours!
    }
    
    func diffInMinutes(_ fromDate: Date, absoluteValue: Bool = true) -> Int {
        let minutes = (Calendar.current as NSCalendar).components(.minute, from: self, to: fromDate, options: []).minute
        return absoluteValue ? abs(minutes!) : minutes!
    }
    
    func diffInSeconds(_ fromDate: Date, absoluteValue: Bool = true) -> Int {
        let seconds = (Calendar.current as NSCalendar).components(.second, from: self, to: fromDate, options: []).second
        return absoluteValue ? abs(seconds ?? 0) : (seconds ?? 0)
    }
    
    func diffInMiliSeconds(_ fromDate: Date, absoluteValue: Bool = true) -> Int {
        abs(Int(timeIntervalSince(fromDate) * 1000))
    }
    
    func isBetween (_ first: Date, second: Date) -> Bool {
        (first < self) && (self < second )
    }
}

extension Date {
    var year: Int { Calendar.current.dateComponents([.year], from: self).year! }
    var month: Int { Calendar.current.dateComponents([.month], from: self).month! }
    var monthFullName: String { toString(format: "MMMM") }
    var day: Int { Calendar.current.dateComponents([.day], from: self).day! }
    var weekday: Int { Calendar.current.dateComponents([.weekday], from: self).weekday! }
    var weekdaySymbol: String { Calendar.current.weekdaySymbols[weekday - 1] }
    var weekdayOrdinal: Int { Calendar.current.dateComponents([.weekdayOrdinal], from: self).weekdayOrdinal! }
    var weekOfMonth: Int { Calendar.current.dateComponents([.weekOfMonth], from: self).weekOfMonth! }
    var weekOfYear: Int { Calendar.current.dateComponents([.weekOfYear], from: self).weekOfYear! }
}
