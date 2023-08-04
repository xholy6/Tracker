//
//  TrackerCategoryDataStore.swift
//  Tracker
//
//  Created by D on 30.07.2023.
//

import Foundation
import CoreData

final class TrackerCategoryDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerCategoryDataStore {
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    
    func category(with name: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let predicate = NSPredicate(format: "%K MATCHES[cd] %@", #keyPath(TrackerCategoryCoreData.title), name)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let categoriesCoreData = try? context.fetch(request)
        return categoriesCoreData?.first
    }
    
    func add(newCategory: TrackerCategory) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = newCategory.title
        saveContext()
    }
    
    func delete(_ record: NSManagedObject) throws {
        context.delete(record)
        saveContext()
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
