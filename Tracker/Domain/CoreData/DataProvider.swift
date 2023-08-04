//
//  DataProvider.swift
//  Tracker
//
//  Created by D on 03.08.2023.
//

import Foundation
import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackersDataProviderDelegate: AnyObject {
    func didUpdate(update: TrackersStoreUpdate)
}

protocol TrackersDataProviderCompletingProtocol {
    func completeTracker(with id: String, date: Date)
    func incompleteTracker(with id: String, date: Date)
}

protocol TrackersDataProviderFetchingProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTrackers(currentDay: String)
    func fetchTrackers(titleSearchString: String, currentDay: String)
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData]
    func completedTimesCount(trackerId: String) -> Int
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
}


final class DataProvider: NSObject {
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStore
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    private let trackerRecordDataStore: TrackerRecordDataStore
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    weak var delegate: TrackersDataProviderDelegate?
    
    private var currentDay = Date().stringDate
    
    private lazy var fetchingResultController: NSFetchedResultsController = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        request.sortDescriptors = sortDescriptors
        
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.schedule), currentDay )
        request.predicate = predicate
        
        let fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        fetchController.delegate = self
        try? fetchController.performFetch()
        return fetchController
        
    }()
    
    init?(trackerDataStore: TrackerDataStore?,
          trackerCategoryDataStore: TrackerCategoryDataStore?,
          trackerRecordDataStore: TrackerRecordDataStore?)
    {
        guard
            let trackerDataStore = trackerDataStore,
            let trackerCategoryDataStore = trackerCategoryDataStore,
            let trackerRecordDataStore = trackerRecordDataStore
        else { return nil }
        
        self.context = trackerDataStore.managedObjectContext
        self.trackerDataStore = trackerDataStore
        self.trackerCategoryDataStore = trackerCategoryDataStore
        self.trackerRecordDataStore = trackerRecordDataStore
    }
    
    func add(tracker: Tracker, for categoryName: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = ScheduleMarshalling.toStringFrom(array: tracker.schedule ?? [String]() )
        trackerCoreData.colorHex = UIColorMarshalling.serilizeToHex(color: tracker.color ?? .black)
        trackerCoreData.id = tracker.id
        let categoryCoreData = trackerCategoryDataStore.addTrackerCategory(from: categoryName)
        trackerDataStore.addTracker(trackerCoreData, to: categoryCoreData)
    }
}
//MARK: - TrackersDataProviderCompletingProtocol
extension DataProvider: TrackersDataProviderCompletingProtocol {
    func completeTracker(with id: String, date: Date) {
        try? trackerRecordDataStore.completeTracker(with: id, date: date)
    }
    
    func incompleteTracker(with id: String, date: Date) {
        guard let record = trackerRecordDataStore.record(with: id, date: date as NSDate) else { return }
        try? trackerRecordDataStore.incompleteTracker(record)
    }
    
    
}
//MARK: - TrackersDataProviderFetchingProtocol
extension DataProvider: TrackersDataProviderFetchingProtocol {
    var numberOfSections: Int {
        fetchingResultController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchingResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchTrackers(currentDay: String) {
        fetchingResultController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.schedule), currentDay)
        try? fetchingResultController.performFetch()
    }
    
    func fetchTrackers(titleSearchString: String, currentDay: String) {
        fetchingResultController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.name), titleSearchString,
            #keyPath(TrackerCoreData.schedule), currentDay)
        try? fetchingResultController.performFetch()
    }
    
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData] {
        let trackerRecordsCoreData = trackerRecordDataStore.completedTrackers(for: date as NSDate)
        return trackerRecordsCoreData
    }
    
    func completedTimesCount(trackerId: String) -> Int {
        let count = try? trackerRecordDataStore.completedTimesCount(trackerId: trackerId)
        return count ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> TrackerCoreData? {
        fetchingResultController.object(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        guard let sections = fetchingResultController.sections,
              indexPath.section < sections.count,
              indexPath.row < sections[indexPath.section].numberOfObjects else {
            return nil
        }
        let trackerCoreData = fetchingResultController.object(at: indexPath)
        return trackerCoreData.category?.title
    }
    
    
}
// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        delegate?.didUpdate(update: TrackersStoreUpdate(
            insertedIndexes: insertedIndexes!,
            deletedIndexes: deletedIndexes!))
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,                      didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
