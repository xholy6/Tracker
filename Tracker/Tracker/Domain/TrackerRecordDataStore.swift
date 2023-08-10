//
//  TrackerRecordDataStore.swift
//  Tracker
//
//  Created by D on 30.07.2023.
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
    var managedObjectContext: NSManagedObjectContext {
        context
    }
    
    func completeTracker(with id: String, date: Date) throws {
        let record = TrackerRecordCoreData(context: context)
        record.idTracker = id
        record.date = date
        try context.save()
    }
    
    func incompleteTracker(_ record: TrackerRecordCoreData) throws {
        context.delete(record)
        try context.save()
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
            #keyPath(TrackerRecordCoreData.idTracker), id,
            #keyPath(TrackerRecordCoreData.date), date)
        request.predicate = predicate
        request.fetchLimit = 1
        
        let records = try? context.fetch(request)
        return records?.first
    }
    
    func completedTimesCount(trackerId: String) throws -> Int {
           let request = TrackerRecordCoreData.fetchRequest()
           let predicate = NSPredicate(
               format: "%K == %@",
               #keyPath(TrackerRecordCoreData.idTracker), trackerId)
           request.predicate = predicate
           request.resultType = .countResultType

           let fetchResult = try context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
           guard
               let count = fetchResult.finalResult?.first,
               let countInt = count as? Int
           else { return 0 }

           return countInt
       }
}

