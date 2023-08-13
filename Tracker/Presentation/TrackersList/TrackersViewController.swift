//
//  ViewController.swift
//  Tracker
//
//  Created by D on 25.04.2023.
//

import UIKit

protocol DataServiceCollectionProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func tracker(at indexPath: IndexPath) -> Tracker?
    func categoryTitle(at indexPath: IndexPath) -> String?
}

final class TrackersViewController: UIViewController {
    //MARK: - Properties
    private var completedTrackers: Set<TrackerRecord> = []
    
    private let trackersDataService = TrackersDataService.shared
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentDate: Date {
        let date = datePicker.date
        let currentDate = date.getTomorrowDate
        return currentDate
    }
    
    private var today: Date {
        let date = Date()
        let today = date.getTomorrowDate
        return today
    }
    
    //MARK: - UI objects
    private lazy var addNewTrackerButton: UIBarButtonItem = {
        let image = UIImage(named: "plusButton")
        let button = UIBarButtonItem(image: image,
                                     style: .done,
                                     target: self,
                                     action: #selector(addNewTracker))
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .iso8601)
        datePicker.addTarget(self, action: #selector(choosedDateInDatePicker), for: .valueChanged)
        
        return datePicker
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerCell.self,
                                forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(
            HeaderReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HeaderReusableView.headerIdentifier)
        collectionView.alwaysBounceVertical = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private lazy var plugView: PlugView = {
        let plugView = PlugView(
            frame: .zero,
            titleLabel: "Что будем отслеживать?",
            image: UIImage(named: "plugStar") ?? UIImage()
        )
        plugView.isHidden = true
        return plugView
    }()
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchController()
        requestTracker(for: datePicker.date)
    }
    //MARK: - Private functions
    private func requestTracker(for day: Date) {
        let count = trackersDataService.fetchTrackers(weekDay: day.stringDate)
        fetchCompletedTrackersForCurrentDate()
        shouldShowPlugview(trackers: count, isSearching: false)
        collectionView.reloadData()
    }
    
    private func fetchCompletedTrackersForCurrentDate() {
        let completedTrackersForCurrentDate = trackersDataService.fetchCompletedRecords(date: currentDate)
        self.completedTrackers = Set(completedTrackersForCurrentDate)
    }
    
    private func shouldShowPlugview(trackers count: Int, isSearching: Bool) {
        switch isSearching {
        case true:
            plugView.config(title: "Ничего не найдено",
                            image: UIImage(named: "notFound"))
        default:
            plugView.config(title: "Что будем отслеживать?",
                            image: UIImage(named: "plugStar"))
        }
        plugView.isHidden = count != 0 ? true : false
    }
    
    @objc
    private func addNewTracker() {
        let vc = ChooseTypeTrackerViewController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc
    private func choosedDateInDatePicker() {
        requestTracker(for: datePicker.date)
    }
    //MARK: - Setup UI objects
    private func setupView() {
        view.backgroundColor = .white
        view.addSubViews(collectionView, plugView)
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        searchController.delegate = self
        searchController.searchBar.setValue("Отмена", forKey: "cancelButtonText")
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func checkTracker(id: String?, completed: Bool) {
        guard let id = id else { return }
        let completedTracker = TrackerRecord(doneId: id, date: currentDate)
        if completed {
            completedTrackers.insert(completedTracker)
            trackersDataService.completeTracker(trackerId: id, date: currentDate)
        } else {
            trackersDataService.incompleteTracker(trackerId: id, date: currentDate)
            completedTrackers.remove(completedTracker)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath)
                as? TrackerCell else { return UICollectionViewCell() }
        
        guard let tracker = tracker(at: indexPath) else { return UICollectionViewCell()}
        let completedDayCount = trackersDataService.completedTimesCount(trackerId: tracker.id)
        let isCompleted = completedTrackers
            .first(where: { $0.doneId == tracker.id && $0.date.isDayEqualTo(currentDate) }) != nil
        cell.configCell(tracker: tracker, completedDaysCount: completedDayCount, completed: isCompleted)
        cell.enabledCheckTrackerButton(enabled: today > datePicker.date)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: HeaderReusableView.headerIdentifier,
            for: indexPath
        ) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        guard let title = categoryTitle(at: indexPath) else { view.config(title: "")
            return view
        }
        view.config(title: title)
        return view
    }
}
//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width - 44) / 2
        let heightConstant: CGFloat = 132
        let size = CGSize(width: width, height: heightConstant)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height / 20
        return CGSize(width: width, height: height)
    }
}

//MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            let count = trackersDataService.fetchTrackers(titleSearchString: text,
                                                          currentWeekDay: currentDate.stringDate)
            collectionView.reloadData()
            shouldShowPlugview(trackers: count, isSearching: true)
        }
    }
}

//MARK: - UISearchControllerDelegate
extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        requestTracker(for: currentDate)
    }
}

extension TrackersViewController: ChooseTypeTrackerViewControllerDelegate {
    func dimissVC(_ viewcontroller: UIViewController) {
        dismiss(animated: true)
    }
    
    func shouldUpdateTrackers() {
        requestTracker(for: datePicker.date)
    }
}
//MARK: - DataServiceCollectionProtocol
extension TrackersViewController: DataServiceCollectionProtocol {
    var numberOfSections: Int {
        trackersDataService.numberOfSections
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        trackersDataService.numberOfItemsInSection(section)
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        trackersDataService.tracker(at: indexPath)
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String? {
        trackersDataService.categoryTitle(at: indexPath)
    }
    
}
