//
//  ViewController.swift
//  Tracker
//
//  Created by D on 25.04.2023.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    //MARK: - Properties
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var filteredCategories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var currentDate: Date {
        let date = datePicker.date
        let currentDate = date.getDate
        return currentDate
    }
    
    private var today: Date {
        let date = Date()
        let today = date.getDate
        return today
    }
    
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
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
        datePicker.addTarget(self, action: #selector(changeDate), for: .valueChanged)
        
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
            withReuseIdentifier: HeaderReusableView.identifier)
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
        showVisibleTrackers()
    }
    
    //MARK: - Private functions
    @objc
    private func addNewTracker() {
        let vc = ChooseTypeTrackerViewController()
        vc.delegate = self
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
    
    @objc
    private func changeDate() {
        showVisibleTrackers()
    }
    
    private func getDayCount(for id: String) -> Int {
        var completedDaysCount = 0
        completedTrackers.forEach {
            if $0.doneId == id { completedDaysCount += 1 }
        }
        return completedDaysCount
    }
    
    private func getTracker(for indexPath: IndexPath) -> Tracker {
        isFiltering ? filteredCategories[indexPath.section].trackers[indexPath.row] : visibleCategories[indexPath.section].trackers[indexPath.row]
    }
    
    private func showVisibleTrackers() {
        visibleCategories = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E"
        let date = dateFormatter.string(from: datePicker.date)
        
        var newCategories: [TrackerCategory] = []
        
        for (index, category) in categories.enumerated() {
            var trackers: [Tracker] = []
            for tracker in category.trackers {
                guard let weekDays = tracker.schedule else { return }
                print("xxzxaadasdasdasdasda \(weekDays)")
                for weekDay in weekDays {
                    if weekDay == date {
                        trackers.append(tracker)
                        print("xxxxxxxasda\(trackers)")
                    } else {
                        continue
                    }
                }
                guard !trackers.isEmpty else {
                    presentedViewController?.dismiss(animated: false, completion: nil)
                    plugView.isHidden = false
                    continue
                }
                
                let newCategory = TrackerCategory(title: category.title, trackers: trackers)
                
                if newCategories.contains(newCategory) {
                    let trackers = newCategory.trackers
                    let newTrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
                    newCategories[index] = newTrackerCategory
                } else {
                    newCategories.append(newCategory)
                }
            }
            
            visibleCategories = newCategories
            print("hi")
            plugView.isHidden = visibleCategories.isEmpty ? false : true
            print(plugView.isHidden)
            print(visibleCategories)
            collectionView.reloadData()
            presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    //MARK: - Setup UI objects
    private func setupView() {
        view.backgroundColor = .white
        view.addSubViews(collectionView, plugView)
        navigationItem.leftBarButtonItem = addNewTrackerButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        if categories.isEmpty { plugView.isHidden = false }
        
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
        } else {
            completedTrackers.remove(completedTracker)
        }
    }
}

//MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        isFiltering ? filteredCategories.count : visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        isFiltering ? filteredCategories[section].trackers.count : visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath)
                as? TrackerCell else { return UICollectionViewCell() }
        let tracker = getTracker(for: indexPath)
        let completedDayCount = getDayCount(for: tracker.id)
        var completed = false
        
        completedTrackers.forEach { trackerRecord in
            if trackerRecord.doneId == tracker.id && trackerRecord.date == currentDate {
                completed = true
            }
        }
        
        cell.configCell(tracker: tracker, completedDaysCount: completedDayCount, completed: completed)
        cell.enabledCheckTrackerButton(enabled: today < currentDate)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderReusableView.identifier, for: indexPath) as? HeaderReusableView else {
            return UICollectionReusableView()
        }
        
        let title: String
        
        if isFiltering {
            title = filteredCategories[indexPath.section].title
        } else {
            title = visibleCategories[indexPath.section].title
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

//MARK: - UIS

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text == "" {
            filteredCategories = []
        } else {
            filterContentForSearchText(searchController.searchBar.text)
        }
    }
    
    private func filterContentForSearchText (_ searchText: String?) {
        guard let searchText else { return }
        var newCategories: [TrackerCategory] = []
        
        for category in visibleCategories {
            var trackers: [Tracker] = []
            
            for (index, tracker) in category.trackers.enumerated() {
                if tracker.name.lowercased().contains(searchText.lowercased()){
                    if trackers.contains(tracker) {
                        trackers[index] = tracker
                    } else {
                        trackers.append(tracker)
                    }
                }
            }
            
            let category = TrackerCategory(title: category.title, trackers: trackers)
            
            if newCategories.contains(category) {
                guard let index = newCategories.firstIndex(of: category) else { return }
                newCategories[index] = category
            }
            else {
                newCategories.append(category)
            }
        }
        
        filteredCategories = newCategories
        
        if filteredCategories.isEmpty && searchText != "" {
            plugView.isHidden = false
            plugView.config(title: "Ничего не найдено", image: UIImage(named: "notFound"))
        } else {
            plugView.isHidden = true
        }
        collectionView.reloadData()
    }
}

extension TrackersViewController: UISearchControllerDelegate {
    func didDismissSearchController(_ searchController: UISearchController) {
        filteredCategories = []
        let plusIsHidden = categories.isEmpty ? false : true
        plugView.isHidden = plusIsHidden
        plugView.config(
            title: "Что будем отслеживать?",
            image: UIImage(named: "plugStar")
        )
        collectionView.reloadData()
    }
}

extension TrackersViewController: ChooseTypeTrackerViewControllerDelegate {
    func dimissVC(_ viewcontroller: UIViewController) {
        dismiss(animated: true)
    }
    
    func createTrackerCategory(_ trackerCategory: TrackerCategory?) {
        print("1231\(trackerCategory)")
        guard let trackerCategory else { return }
        guard !categories.contains(trackerCategory) else {
            for (index, category) in categories.enumerated() {
                if category.title == trackerCategory.title {
                    let trackers = category.trackers + trackerCategory.trackers
                    let newTrackerCategory = TrackerCategory(title: category.title, trackers: trackers)
                    categories[index] = newTrackerCategory
                }
            }
            showVisibleTrackers()
            dismiss(animated: true)
            return
        }
        categories.append(trackerCategory)
        if !categories.isEmpty { plugView.isHidden = true }
        print(categories)
        showVisibleTrackers()
        dismiss(animated: true)
    }
}
