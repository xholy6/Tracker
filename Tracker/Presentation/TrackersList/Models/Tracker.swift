//
//  Tracker.swift
//  Tracker
//
//  Created by D on 13.05.2023.
//

import UIKit

struct Tracker {
    let id: String
    let name: String
    let color: UIColor?
    let emoji: String
    let schedule: [String]?
    let isPinned: Bool?
}

extension Tracker: Equatable {
    static func == (lrh: Tracker, rhs: Tracker) -> Bool {
        lrh.id == rhs.id ? true : false
    }
}
