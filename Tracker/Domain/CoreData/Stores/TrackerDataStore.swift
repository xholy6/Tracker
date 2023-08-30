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

    func delete(_ tracker: TrackerCoreData) {
        context.delete(tracker)
        saveContext()
    }

    func updateCategory(tracker: TrackerCoreData, to category: TrackerCategoryCoreData?) {
        tracker.category?.removeFromTrackers(tracker)
        category?.addToTrackers(tracker)
        tracker.category = category
        saveContext()
    }

    func getTracker(with id: String) -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCoreData.id), id)
        request.predicate = predicate

        let tracker = try? context.fetch(request).first
        return tracker

    }
    
}
