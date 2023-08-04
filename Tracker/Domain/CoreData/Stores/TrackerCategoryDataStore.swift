//
//  TrackerCategoryDataStore.swift
//  Tracker
//
//  Created by D on 03.08.2023.
//

import Foundation
import CoreData

final class TrackerCategoryDataStore {
    
    private enum TrackerStoreError: Error {
        case errorDecodingCategoryTitle
    }
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
}

extension TrackerCategoryDataStore {
    
    func addTrackerCategory(from category: String) -> TrackerCategoryCoreData {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category
        saveContext()
        return trackerCategoryCoreData
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}


