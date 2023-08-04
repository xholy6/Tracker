//
//  scheduleMarshalling.swift
//  Tracker
//
//  Created by D on 03.08.2023.
//

import Foundation

struct ScheduleMarshalling {
    
    static func toStringFrom(array: [String]) -> String {
        return array.joined(separator: ",")
    }

    static func toArrayFrom(string: String) -> [String] {
        return string.components(separatedBy: ",")
    }
}
