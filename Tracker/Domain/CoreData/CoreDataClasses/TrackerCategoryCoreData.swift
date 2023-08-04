//
//  TrackerCategoryCoreData+CoreDataClass.swift
//  Tracker
//
//  Created by D on 04.08.2023.
//
//

import Foundation
import CoreData

@objc(TrackerCategoryCoreData)
class TrackerCategoryCoreData: NSManagedObject {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }
    
    @NSManaged var title: String?
    @NSManaged var trackers: NSSet?
    
}

// MARK: Generated accessors for trackers
extension TrackerCategoryCoreData {
    
    @objc(addTrackersObject:)
    @NSManaged func addToTrackers(_ value: TrackerCoreData)
    
    @objc(removeTrackersObject:)
    @NSManaged func removeFromTrackers(_ value: TrackerCoreData)
    
    @objc(addTrackers:)
    @NSManaged func addToTrackers(_ values: NSSet)
    
    @objc(removeTrackers:)
    @NSManaged func removeFromTrackers(_ values: NSSet)
    
}

