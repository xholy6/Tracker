//
//  TrackerCategory.swift
//  Tracker
//
//  Created by D on 13.05.2023.
//

import Foundation

struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

extension TrackerCategory: Equatable {
    static func == (lrh: TrackerCategory, rhs: TrackerCategory) -> Bool {
        lrh.title == rhs.title ? true : false
    }
}
