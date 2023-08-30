//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by D on 15.08.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() throws {
        let vc = TrackersViewController()

        assertSnapshots(
            matching: vc,
            as: [.image(traits: .init(userInterfaceStyle: .light)) ])

        assertSnapshots(
            matching: vc,
            as: [.image(traits: .init(userInterfaceStyle: .dark)) ])
    }
}

