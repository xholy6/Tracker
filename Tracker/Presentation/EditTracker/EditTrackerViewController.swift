//
//  EditTrackerViewController.swift
//  Tracker
//
//  Created by D on 14.08.2023.
//

protocol EditTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
    func shouldUpdateTrackersAfterEdit()
}

import UIKit

final class EditTrackerViewController: UIViewController {

    weak var delegate: EditTrackerViewControllerDelegate?

    private let trackersDataService = TrackersDataService.shared

    private let emojiesSectionTitle = "Emoji"
    private let colorsSectionTitle = "Цвет"
    private let vctitle = "Редактирование привычки"

    private var tracker: Tracker?
    private var trackerType: TrackerType?
    private var category: String?
    private var engSchedule: [String]?
    private var schedule: [String]?

    private var nameTracker: String?
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private var emojiSelectedItem: Int?
    private var colorSelectedItem: Int?

    var indexPath: IndexPath?

    private var editTrackerView: EditTrackerView!

    private var tableViewCellTitle = [
        ScheduleCategoryTableViewModel(name: "Категория", description: nil),
        ScheduleCategoryTableViewModel(name: "Расписание", description: nil),
    ]

    //MARK: - CollectionViewItems
    private let emojies = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]

    private let colors = [
        UIColor.ypColor1,
        UIColor.ypColor2,
        UIColor.ypColor3,
        UIColor.ypColor4,
        UIColor.ypColor5,
        UIColor.ypColor6,
        UIColor.ypColor7,
        UIColor.ypColor8,
        UIColor.ypColor9,
        UIColor.ypColor10,
        UIColor.ypColor11,
        UIColor.ypColor12,
        UIColor.ypColor13,
        UIColor.ypColor14,
        UIColor.ypColor15,
        UIColor.ypColor16,
        UIColor.ypColor17,
        UIColor.ypColor18,
    ].compactMap { color in
        if let color { return color }
        return nil
    }
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = vctitle
        prepView()
        setupView()
        editTrackerView.setupTableView(delegate: self, dataSource: self)
        editTrackerView.setupCollectionView(delegate: self, dataSource: self)

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.shouldUpdateTrackersAfterEdit()
    }

    //MARK: - Private functions
    private func setCategory(category: String?) {
        tableViewCellTitle[0].description = category
        editTrackerView.refreshTableView()
    }

    private func setSchedule(schedule: String?) {
        tableViewCellTitle[1].description = schedule
        editTrackerView.refreshTableView()
    }

    private func showScheduleViewController() {
        let vc = ChooseScheduleViewController()
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }

    private func showCategoryViewController() {
        let viewModel = CategoriesViewModel()
        viewModel.delegate = self
        let vc = CategoriesVC()
        vc.viewModel = viewModel
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true)
    }
    //MARK: - Setup view
    private func setupView() {
        view.addSubview(editTrackerView)
        NSLayoutConstraint.activate([
            editTrackerView.topAnchor.constraint(equalTo: view.topAnchor),
            editTrackerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            editTrackerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            editTrackerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    //MARK: - Preparate view
    private func prepView() {
        tracker = trackersDataService.tracker(at: indexPath ?? [0,0])
        trackerType = tracker?.type
        category = trackersDataService.categoryTitle(at: indexPath ?? [0,0])
        let count = trackersDataService.completedTimesCount(trackerId: tracker?.id ?? "")
        let schedule = tracker?.schedule?.flatMap { $0.components(separatedBy: ",") }
        let ruString = schedule?.compactMap {$0.weekDay?.shortString}.joined(separator: ", ")
        editTrackerView = EditTrackerView(frame: view.bounds,
                                          delegate: self,
                                          trackerType: tracker?.type ?? .habit,
                                          trackerName: tracker?.name ?? "",
                                          dayCount: String(count))
        setSchedule(schedule: ruString)
        setCategory(category: category)
        selectedEmoji = tracker?.emoji
        selectedColor = tracker?.color
        engSchedule = schedule

    }
}
extension EditTrackerViewController: ChooseScheduleViewControllerDelegate {
    func getSchedule(selectedDays: [WeekDay]) {
        engSchedule = selectedDays.map {$0.engString}
        let daysString = selectedDays.map{$0.shortString}
        schedule = daysString
        setSchedule(schedule: schedule?.joined(separator: ", "))
    }
}

extension EditTrackerViewController: CategoriesViewModelDelegate {
    func getCategory(with name: String) {
        category = name
        setCategory(category: name)
    }
}
//MARK: - UITableViewDataSource
extension EditTrackerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch trackerType {
        case .habit:
            return 2
        case .irregularEvent:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: ScheduleAndCategoryCell.indentifier)
        cell.backgroundColor = .ypLightGray
        cell.detailTextLabel?.font = .ypRegular17
        cell.detailTextLabel?.textColor = .ypGray
        cell.textLabel?.text = tableViewCellTitle[safe: indexPath.row]?.name
        cell.detailTextLabel?.text = tableViewCellTitle[safe: indexPath.row]?.description
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

}
//MARK: - UITableViewDelegate
extension EditTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            tableView.cellForRow(at: indexPath)?.isSelected = false
            showCategoryViewController()
        case 1:
            tableView.cellForRow(at: indexPath)?.isSelected = false
            showScheduleViewController()
        default:
            print("")
        }
    }
}
//MARK: - UICollectionViewDataSource
extension EditTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emojies.count
        default:
            return colors.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {

        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            cell.config(emoji: emojies[safe: indexPath.row])
            if emojies[safe: indexPath.row] == selectedEmoji {
                cell.isCellSelected = true
                emojiSelectedItem = indexPath.item
            }
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.identifier,
                for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            cell.config(color: colors[safe: indexPath.row])
            let cellColorHex = UIColorMarshalling.serilizeToHex(color: colors[indexPath.row])
            let trackerColorHex = UIColorMarshalling.serilizeToHex(color: selectedColor!)
            if cellColorHex == trackerColorHex {
                cell.isCellSelected = true
                colorSelectedItem = indexPath.item
            }
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view: UICollectionReusableView

        switch indexPath.section {
        case 0:
            guard
                kind == UICollectionView.elementKindSectionHeader,
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HeaderReusableView.headerIdentifier,
                    for: indexPath) as? HeaderReusableView
            else {
                return UICollectionReusableView()
            }
            view.config(title: emojiesSectionTitle)
            return view
        case 1:
            guard
                kind == UICollectionView.elementKindSectionHeader,
                let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HeaderReusableView.headerIdentifier,
                    for: indexPath) as? HeaderReusableView
            else {
                return UICollectionReusableView()
            }
            view.config(title: colorsSectionTitle)
            return view
        default: view = UICollectionReusableView()
        }

        return view
    }


}
//MARK: - UICollectionViewDelegateFlowLayout
extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let bounds = editTrackerView.bounds
        let leftInset: CGFloat = 16
        let rightInset: CGFloat = 16
        let horizontalCellSpacing: CGFloat = 10
        let cellsPerRow: CGFloat = 6
        let cellsHorizontalSpace = leftInset + rightInset + horizontalCellSpacing * cellsPerRow
        let width = (bounds.width - cellsHorizontalSpace) / cellsPerRow
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = editTrackerView.bounds.width
        let height = editTrackerView.bounds.height / 9

        return CGSize(width: width, height: height)
    }
}
//MARK: - UICollectionViewDelegate
extension EditTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            let prevCell = collectionView.cellForItem(at: IndexPath(item: emojiSelectedItem ?? 0, section: 0)) as? EmojiCollectionViewCell
            cell?.isCellSelected  = true
            prevCell?.isCellSelected = false
            emojiSelectedItem = indexPath.item
            guard let emojiSelectedItem else { return }
            selectedEmoji = emojies[safe: emojiSelectedItem]

        case 1:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            let prevCell = collectionView.cellForItem(at: IndexPath(item: colorSelectedItem ?? 0, section: 1)) as? ColorCollectionViewCell
            cell?.isCellSelected  = true
            prevCell?.isCellSelected = false
            colorSelectedItem = indexPath.item
            guard let colorSelectedItem else { return }
            selectedColor = colors[safe: colorSelectedItem]
        default:
            break
        }
    }
}

//MARK: - EditTrackerViewDelegate
extension EditTrackerViewController: EditTrackerViewDelegate {
    func cancelCreation() {
        dismiss(animated: true)
    }

    func textFieldDidChanged(text: String) -> Bool {
        return text.count >= 38 ? false : true
    }

    func sendTrackerName(trackerName: String?) {
        nameTracker = trackerName
        guard
            let nameTracker,
            let selectedEmoji,
            let selectedColor,
            let category,
            engSchedule != nil
        else { return }
        tracker = Tracker(id: tracker?.id ?? "",
                          name: nameTracker,
                          color: selectedColor,
                          emoji: selectedEmoji,
                          schedule: engSchedule,
                          isPinned: false,
                          type: trackerType)
        guard let tracker else { return }
        trackersDataService.updateTracker(with: tracker.id, by: tracker, for: category)
        delegate?.dismissViewController(self)

    }

}
