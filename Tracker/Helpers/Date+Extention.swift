//
//  Date+Extention.swift
//  Tracker
//
//  Created by D on 20.06.2023.
//

import Foundation

extension Date {
    var getTomorrowDate: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let date = Calendar.current.date(from: dateComponents)
        return date?.addingTimeInterval(24*3600) ?? Date()
    }
    
    var stringDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
    
    func isDayEqualTo(_ otherDate: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: otherDate, toGranularity: .day)
    }
}

