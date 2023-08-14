//
//  TrackersDataService.swift
//  Tracker
//
//  Created by D on 04.08.2023.
//

import UIKit

protocol TrackersServiceDataSourceProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

protocol TrackersServiceAddingAndUpdatingProtocol {
    func addTracker(category: String, tracker: Tracker)
    func addCategory(category: String)
    func updateCategory(oldTitle: String, newTitle: String)
    func updateTracker(with id: String, by tracker: Tracker, for category: String) 
    func createPinnedCategory()
    func pinTracker(_ id: String)
    func unpinTracker(_ id: String)
}

protocol TrackersServiceDeletingProtocol {
    func deleteCategory(category: String)
    func deleteTracker(with id: String)
}

protocol TrackersServiceCompletingProtocol {
    func completeTracker(trackerId id: String, date: Date)
    func incompleteTracker(trackerId id: String, date: Date)
}

protocol TrackersServiceFetchingProtocol {
    func fetchAllCategoires() -> [String]
    func fetchTrackers(weekDay: String) -> Int
    func fetchTrackers(titleSearchString: String, currentWeekDay: String) -> Int
    func fetchCompletedRecords(date: Date) -> [TrackerRecord]
    func completedTimesCount(trackerId: String) -> Int
    
    func requestDataProviderErrorAlert()
}

typealias TrackersServiceFetchingCompletingProtocol =
TrackersServiceFetchingProtocol
& TrackersServiceCompletingProtocol

typealias TrackersServiceProtocol =
TrackersServiceAddingAndUpdatingProtocol
& TrackersServiceCompletingProtocol
& TrackersServiceFetchingProtocol
& TrackersServiceDataSourceProtocol
& TrackersServiceDeletingProtocol

// MARK: - TrackersService
final class TrackersDataService {
    
    static let shared: TrackersServiceProtocol = TrackersDataService()
    
    private let trackersDataProvider: DataProvider?
    
    private init(trackerDataProvider: DataProvider?) {
        self.trackersDataProvider = trackerDataProvider
    }
    
    private convenience init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let trackerDataStore = appDelegate.trackerDataStore
        let trackerCategoryDataStore = appDelegate.trackerCategoryDataStore
        let trackerRecordDataStore = appDelegate.trackerRecordDataStore
        
        if let trackerDataProvider = DataProvider(
            trackerDataStore: trackerDataStore,
            trackerCategoryDataStore: trackerCategoryDataStore,
            trackerRecordDataStore: trackerRecordDataStore
        ) {
            self.init(trackerDataProvider: trackerDataProvider)
        } else {
            self.init(trackerDataProvider: nil)
            self.requestDataProviderErrorAlert()
        }
    }
}

// MARK: - TrackersServiceFetchingProtocol
extension TrackersDataService: TrackersServiceFetchingProtocol {
    func requestDataProviderErrorAlert() { print("data provider error") }
    
    func fetchTrackers(weekDay: String) -> Int {
        trackersDataProvider?.fetchTrackers(currentDay: weekDay) ?? 0
    }
    
    func fetchTrackers(titleSearchString: String, currentWeekDay: String) -> Int {
        trackersDataProvider?.fetchTrackers(titleSearchString: titleSearchString, currentDay: currentWeekDay) ?? 0
    }
    
    func fetchAllCategoires() -> [String] {
        trackersDataProvider?.fetchAllCategories() ?? [String]()
    }
    
    func fetchCompletedRecords(date: Date) -> [TrackerRecord] {
        let trackerRecordsCoreData = trackersDataProvider?.fetchCompletedRecords(date: date)
        let trackerRecords = trackerRecordsCoreData?.compactMap { trackerRecordCoreData -> TrackerRecord? in
            guard let id = trackerRecordCoreData.doneId else { return nil }
            return TrackerRecord(doneId: id, date: trackerRecordCoreData.date ?? Date())
        }
        return trackerRecords ?? []
    }
    
    func completedTimesCount(trackerId: String) -> Int {
        trackersDataProvider?.completedTimesCount(trackerId: trackerId) ?? 0
    }
}

// MARK: - TrackersServiceCompletingProtocol
extension TrackersDataService: TrackersServiceCompletingProtocol {
    func completeTracker(trackerId: String, date: Date) {
        trackersDataProvider?.completeTracker(with: trackerId, date: date)
    }
    
    func incompleteTracker(trackerId: String, date: Date) {
        trackersDataProvider?.incompleteTracker(with: trackerId, date: date)
    }
}

// MARK: - TrackersServiceAddingProtocol
extension TrackersDataService: TrackersServiceAddingAndUpdatingProtocol {
    func addTracker(category: String, tracker: Tracker) {
        try? trackersDataProvider?.add(tracker: tracker, for: category)
    }
    
    func addCategory(category: String) {
        try? trackersDataProvider?.addCategory(category)
    }
    
    func updateCategory(oldTitle: String, newTitle: String) {
        trackersDataProvider?.updateCategoryTitle(oldCategoryTitle: oldTitle, newCategoryTitle: newTitle)
    }

    func updateTracker(with id: String, by tracker: Tracker, for category: String) {
        trackersDataProvider?.updateTracker(with: id, by: tracker, for: category)
    }

    func createPinnedCategory() {
        trackersDataProvider?.createPinnedCategory()
    }

    func pinTracker(_ id: String) {
        trackersDataProvider?.pinTracker(with: id)
    }

    func unpinTracker(_ id: String) {
        trackersDataProvider?.unpinTracker(with: id)
    }
}

extension TrackersDataService: TrackersServiceDeletingProtocol {
    func deleteCategory(category: String) {
        try? trackersDataProvider?.deleteCategory(category)
    }

    func deleteTracker(with id: String) {
        try? trackersDataProvider?.deleteTracker(with: id)
    }
}

// MARK: - TrackersServiceDataSourceProtocol
extension TrackersDataService: TrackersServiceDataSourceProtocol {
    var numberOfSections: Int {
        trackersDataProvider?.numberOfSections ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return trackersDataProvider?.numberOfItemsInSection(section) ?? 0
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        trackersDataProvider?.categoryTitle(at: indexPath)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard
            let trackerCoreData = trackersDataProvider?.tracker(at: indexPath),
            let id = trackerCoreData.id,
            let name = trackerCoreData.name,
            let emoji = trackerCoreData.emoji,
            let color = UIColorMarshalling.deserilizeFrom(hex: trackerCoreData.colorHex ?? String()),
            let type = trackerCoreData.type?.trackerType

        else { return nil }

        let isPinned = trackerCoreData.isPinned
        
        let splittedWeekDays = trackerCoreData.schedule?.components(separatedBy: ", ")
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: splittedWeekDays,
            isPinned: isPinned,
            type: type)
    }
}
