//
//  TrackerCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by D on 04.08.2023.
//
//

import Foundation
import CoreData

@objc(TrackerCoreData)
class TrackerCoreData: NSManagedObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged var colorHex: String?
    @NSManaged var emoji: String?
    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var schedule: String?
    @NSManaged var category: TrackerCategoryCoreData?
    @NSManaged var records: NSSet?
    @NSManaged var prevCategory: String?
    @NSManaged var isPinned: Bool

}

// MARK: Generated accessors for records
extension TrackerCoreData {

    @objc(addRecordsObject:)
    @NSManaged func addToRecords(_ value: TrackerRecordCoreData)

    @objc(removeRecordsObject:)
    @NSManaged func removeFromRecords(_ value: TrackerRecordCoreData)

    @objc(addRecords:)
    @NSManaged func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged func removeFromRecords(_ values: NSSet)

}
