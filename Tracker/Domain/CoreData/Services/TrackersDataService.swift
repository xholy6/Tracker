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

protocol TrackersServiceAddingProtocol {
    func addTracker(category: String, tracker: Tracker)
}

protocol TrackersServiceCompletingProtocol {
    func completeTracker(trackerId id: String, date: Date)
    func incompleteTracker(trackerId id: String, date: Date)
}

protocol TrackersServiceFetchingProtocol {
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
TrackersServiceAddingProtocol
& TrackersServiceCompletingProtocol
& TrackersServiceFetchingProtocol
& TrackersServiceDataSourceProtocol

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
extension TrackersDataService: TrackersServiceAddingProtocol {
    
    func addTracker(category: String, tracker: Tracker) {
        try? trackersDataProvider?.add(tracker: tracker, for: category)
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
            let color = UIColorMarshalling.deserilizeFrom(hex: trackerCoreData.colorHex ?? String())
        else { return nil }
        
        let splittedWeekDays = trackerCoreData.schedule?.components(separatedBy: ", ")
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: splittedWeekDays)
    }
}
