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
            return NSLocalizedString("filterAllTrackers", comment: "")
        case .trackersForToday:
            return NSLocalizedString("trackersForToday", comment: "")
        case .completed:
            return NSLocalizedString("completedTrackers", comment: "")
        case .uncomplited:
            return NSLocalizedString("uncomplitedTrackers", comment: "")
        }
    }
}
