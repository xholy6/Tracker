//
//  DataProvider.swift
//  Tracker
//
//  Created by D on 30.07.2023.
//

import Foundation
import CoreData

struct TrackersStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}


protocol TrackersDataProviderDelegate: AnyObject {
    func didUpdate(update: TrackersStoreUpdate)
    func didRecievedTrackers()
}


protocol TrackersDataProviderFetchProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func fetchTrackers(currentWeekDay: WeekDay)
    func fetchTrackers(nameSearchString: String, currentWeekDay: WeekDay)
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData]
    func completedTimesCount(trackerId: String) -> Int
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

final class DataProvider: NSObject {
    enum DataProviderError: Error {
        case cannotFindCategory
    }
    
    weak var delegate: TrackersDataProviderDelegate?
    private let context: NSManagedObjectContext
    private let trackerDataStore: TrackerDataStore
    private let trackerCategoryDataStore: TrackerCategoryDataStore
    private let trackerRecordDataStore: TrackerRecordDataStore
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
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
    
    private lazy var fetchedResultsController: NSFetchedResultsController = {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let sortDescriptors = [
            NSSortDescriptor(key: #keyPath(TrackerCoreData.category.title), ascending: true),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        request.sortDescriptors = sortDescriptors
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
            cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    
}

extension DataProvider: TrackersDataProviderFetchProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchTrackers(currentWeekDay: WeekDay) {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.schedule),
            currentWeekDay.englishString)
        try? fetchedResultsController.performFetch()
    }
    
    func fetchTrackers(nameSearchString: String, currentWeekDay: WeekDay) {
        fetchedResultsController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.name), nameSearchString,
            #keyPath(TrackerCoreData.schedule), currentWeekDay.englishString)
        try? fetchedResultsController.performFetch()
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
        fetchedResultsController.object(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.category?.title
    }
}

extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(update:
                                TrackersStoreUpdate(insertedIndexes: insertedIndexes!,
                                                    deletedIndexes: deletedIndexes!)
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
