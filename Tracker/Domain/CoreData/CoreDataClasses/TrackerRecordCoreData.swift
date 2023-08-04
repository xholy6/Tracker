//
//  TrackerRecordCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by D on 04.08.2023.
//
//

import Foundation
import CoreData

@objc(TrackerRecordCoreData)
public class TrackerRecordCoreData: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged var date: Date?
    @NSManaged var doneId: String?
    @NSManaged var tracker: TrackerCoreData?
}
