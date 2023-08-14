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
    func fetchTrackers(currentDay: String) -> Int
    func fetchTrackers(titleSearchString: String, currentDay: String) -> Int
    func fetchCompletedRecords(date: Date) -> [TrackerRecordCoreData]
    func completedTimesCount(trackerId: String) -> Int
    func tracker(at indexPath: IndexPath) -> TrackerCoreData?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

protocol TrackersDataProviderPinningProtocol {
    func pinTracker(with id: String)
    func unpinTracker(with id: String)
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
            NSSortDescriptor(key: #keyPath(TrackerCoreData.isPinned), ascending: false),
            NSSortDescriptor(key: #keyPath(TrackerCoreData.name), ascending: true)
        ]
        request.sortDescriptors = sortDescriptors
        
        let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.schedule), currentDay )
        request.predicate = predicate
        
        let fetchController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: #keyPath(TrackerCoreData.category.title),
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
        trackerCoreData.type = tracker.type?.toString
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = ScheduleMarshalling.toStringFrom(array: tracker.schedule ?? [String]() )
        trackerCoreData.colorHex = UIColorMarshalling.serilizeToHex(color: tracker.color ?? .black)
        trackerCoreData.id = tracker.id
        trackerCoreData.isPinned = tracker.isPinned ?? false
        trackerCoreData.prevCategory = categoryName
        guard let categoryCoreData = trackerCategoryDataStore.getNeededCategory(searching: categoryName) else { return }
        trackerDataStore.addTracker(trackerCoreData, to: categoryCoreData)
    }
    
    func addCategory(_ category: String) throws {
        trackerCategoryDataStore.addTrackerCategory(from: category)
    }
    
    func deleteCategory(_ category: String) throws {
        trackerCategoryDataStore.deleteCategory(category)
    }

    func deleteTracker(with id: String) throws {
        guard let tracker = trackerDataStore.getTracker(with: id) else { return }
        trackerDataStore.delete(tracker)
    }

    func updateTracker(with id: String, by updatedTracker: Tracker, for category: String) {
        guard let tracker = trackerDataStore.getTracker(with: id) else { return }
        tracker.emoji = updatedTracker.emoji
        tracker.schedule = ScheduleMarshalling.toStringFrom(array: updatedTracker.schedule ?? [String]())
        tracker.name = updatedTracker.name
        tracker.colorHex = UIColorMarshalling.serilizeToHex(color: updatedTracker.color ?? .black)
        guard let categoryCoreData = trackerCategoryDataStore.getNeededCategory(searching: category) else { return }
        trackerDataStore.addTracker(tracker, to: categoryCoreData)
    }

    func createPinnedCategory() {
        trackerCategoryDataStore.createDefaultPinnedCategory()
    }
    
}
//MARK: - TrackersDataProviderPinningProtocol
extension DataProvider: TrackersDataProviderPinningProtocol {
    func pinTracker(with id: String) {
        guard let tracker = trackerDataStore.getTracker(with: id) else { return }

        let oldCategory = tracker.category
        tracker.prevCategory = oldCategory?.title
        tracker.isPinned = true

        guard
            let pinnedCategory = trackerCategoryDataStore.getNeededCategory(searching: "Pinned")
        else { return }

        trackerDataStore.updateCategory(tracker: tracker, to: pinnedCategory)
    }

    func unpinTracker(with id: String) {
        guard let tracker = trackerDataStore.getTracker(with: id) else { return }

        tracker.isPinned = false
        guard
            let oldCategory = trackerCategoryDataStore.getNeededCategory(searching: tracker.prevCategory ?? "")
        else { return }
        trackerDataStore.updateCategory(tracker: tracker, to: oldCategory)
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
        fetchingResultController.sections?[section].numberOfObjects ?? 0
    }
    
    func fetchTrackers(currentDay: String) -> Int {
        fetchingResultController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.schedule), currentDay)
        return performFetchAndCountObjects()
    }
    
    func fetchTrackers(titleSearchString: String, currentDay: String) -> Int {
        fetchingResultController.fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[cd] %@ AND %K CONTAINS[cd] %@",
            #keyPath(TrackerCoreData.name), titleSearchString,
            #keyPath(TrackerCoreData.schedule), currentDay)
        return performFetchAndCountObjects()
    }
    
    func fetchAllCategories() -> [String] {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let categoriesCoreData = try? context.fetch(fetchRequest)
        guard let categoriesCoreData else { return [String]() }
        let categoriesString = categoriesCoreData.compactMap { $0.title }
        let filteredCategories = categoriesString.filter { $0 != "Pinned" }
        return filteredCategories
    }
    
    func updateCategoryTitle(oldCategoryTitle: String, newCategoryTitle: String) {
        trackerCategoryDataStore.updateCategoryTitleAndRelationships(
            oldCategoryTitle: oldCategoryTitle,
            newCategoryTitle: newCategoryTitle)
    }
    
    private func performFetchAndCountObjects() -> Int {
        do {
            try fetchingResultController.performFetch()
            if let fetchedObjects = fetchingResultController.fetchedObjects {
                return fetchedObjects.count
            } else {
                return 0
            }
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            return 0
        }
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
