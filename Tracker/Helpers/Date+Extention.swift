//
//  Date+Extention.swift
//  Tracker
//
//  Created by D on 20.06.2023.
//

import Foundation

extension Date {
    var getDate: Date {
        let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: self)
        let date = Calendar.current.date(from: dateComponents)
        return date?.addingTimeInterval(24*3600) ?? Date()
    }
}

