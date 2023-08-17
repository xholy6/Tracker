//
//  FIlterTypes.swift
//  Tracker
//
//  Created by D on 14.08.2023.
//

import Foundation

enum FilterTypes: CaseIterable {
    case allTrackers
    case trackersForToday
    case completed
    case uncomplited

    var string: String {
        switch self {
        case .allTrackers:
            return NSLocalizedString("Filter all trackers", comment: "")
        case .trackersForToday:
            return NSLocalizedString("Trackers for today", comment: "")
        case .completed:
            return NSLocalizedString("Completed trackers", comment: "")
        case .uncomplited:
            return NSLocalizedString("Uncomplited trackers", comment: "")
        }
    }
}
