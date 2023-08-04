//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by D on 30.07.2023.
//

import Foundation
import CoreData

final class TrackerDataStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }

    func add(tracker: TrackerCoreData, in category: TrackerCategoryCoreData) throws {
       // category.addToTrackers(tracker)
        try context.save()
    }
}
