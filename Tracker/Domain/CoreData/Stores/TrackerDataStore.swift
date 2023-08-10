//
//  TrackerDataStore.swift
//  Tracker
//
//  Created by D on 03.08.2023.
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
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func addTracker(_ tracker: TrackerCoreData,
                    to category: TrackerCategoryCoreData) {
        category.addToTrackers(tracker)
        saveContext()
    }
}
