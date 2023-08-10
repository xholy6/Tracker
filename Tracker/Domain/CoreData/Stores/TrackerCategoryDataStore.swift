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
    
    func addTrackerCategory(from category: String) {
        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
        trackerCategoryCoreData.title = category
        saveContext()
    }
    
    func deleteCategory(_ category: String) {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.predicate = NSPredicate(
            format: "%K == %@", #keyPath(TrackerCategoryCoreData.title), category)
        let categories = try? context.fetch(request)
        if let categoryToDelete = categories?.first {
            context.delete(categoryToDelete)
            saveContext()
        }
    }
    
    func getNeededCategory(searching category: String) -> TrackerCategoryCoreData? {
        let request = TrackerCategoryCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerCategoryCoreData.title), category)
        request.predicate = predicate
        
        let category = try? context.fetch(request).first
        return category
        
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
}


