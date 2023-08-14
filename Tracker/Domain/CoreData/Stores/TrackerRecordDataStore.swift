//
//  TrackerRecordDataStore.swift
//  Tracker
//
//  Created by D on 03.08.2023.
//

import Foundation
import CoreData

final class TrackerRecordDataStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
}

extension TrackerRecordDataStore {
    
    func completeTracker(with id: String, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.doneId = id
        record.date = date
        saveContext()
    }
    
    func incompleteTracker(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        saveContext()
    }
    
    func completedTimesCount(trackerId: String) throws -> Int {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.doneId), trackerId)
        request.predicate = predicate
        request.resultType = .countResultType
        
        let fetchResult = try context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        guard
            let count = fetchResult.finalResult?.first,
            let countInt = count as? Int
        else { return 0 }
        
        return countInt
    }
    
    func completedTrackers(for date: NSDate) -> [TrackerRecordCoreData] {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        
        let records = try? context.fetch(request)
        return records ?? []
    }
    
    func record(with id: String, date: NSDate) -> TrackerRecordCoreData? {
        let request = TrackerRecordCoreData.fetchRequest()
        let predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.doneId), id,
            #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let records = try? context.fetch(request)
        return records?.first
    }

    func completedTrackersCount() -> Int? {
            let request = TrackerRecordCoreData.fetchRequest()
            do {
                let object = try self.context.fetch(request)
                return object.count
            } catch {
                return nil
            }
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
