import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func dismissViewController(_ viewController: UIViewController)
    func makeTrackerCategory(_ trackerCategory: TrackerCategory?)
}

final class CreateTrackerViewController: UIViewController {
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private struct CreateTrackerViewControllerConstants {
        static let habitTitle = "Новая привычка"
        static let eventTitle = "Новое нерегулярное событие"
    }
    
    private let emojiesSectionTitle = "Emoji"
    private let colorsSectionTitle = "Цвет"
    
    private var tableViewCellTitle = [
        ScheduleCategoryTableViewModel(name: "Категория", description: nil),
        ScheduleCategoryTableViewModel(name: "Расписание", description: nil),
    ]
    
    private var trackerCategory: TrackerCategory?
    private var tracker: Tracker?
    
    private var nameTracker: String?
    private var category: String?
    private var schedule: [String]?
    private var engSchedule: [String]?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private var emojiSelectedItem: Int?
    private var colorSelectedItem: Int?
    private var selectedItem: IndexPath?
    
    private let trackerDataService = TrackersDataService.shared
    
    private var trackerView: CreateTrackerView!
    
    var trackerType: TrackerType!
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
        
        trackerView = CreateTrackerView(frame: view.bounds, delegate: self, trackerType: trackerType)
        setupView()
        trackerView.setupTableView(delegate: self, dataSource: self)
        trackerView.setupCollectionView(delegate: self, dataSource: self)
        guard let trackerType else {
            dismiss(animated: true)
            return
        }
        switch trackerType {
        case .habit: return title = CreateTrackerViewControllerConstants.habitTitle
        case .irregularEvent: return title = CreateTrackerViewControllerConstants.eventTitle
        }
        
    }
    
    //MARK: - Private methods
    private func setupView() {
        view.addSubview(trackerView)
        NSLayoutConstraint.activate([
            trackerView.topAnchor.constraint(equalTo: view.topAnchor),
            trackerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            trackerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
        ])
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
    
    private func setCategory(category: String?) {
        tableViewCellTitle[0].description = category
        trackerView.refreshTableView()
    }
    
    private func setSchedule(schedule: [String]?) {
        tableViewCellTitle[1].description = schedule?.count == 7 ? "Каждый день" : schedule?.joined(separator: ", ")
        trackerView.refreshTableView()
    }
    
    private func makeAnNonRegularSchedule() {
        if engSchedule?.isEmpty ?? true && trackerType == .irregularEvent {
            engSchedule = WeekDay.allCases.map { $0.engString }
        }
    }
}

//MARK: - CreateTrackerViewDelegate
extension CreateTrackerViewController: CreateTrackerViewDelegate {
    func sendTrackerName(trackerName: String?) {
        makeAnNonRegularSchedule()
        nameTracker = trackerName
        guard
            let nameTracker,
            let selectedEmoji,
            let selectedColor,
            let category,
            engSchedule != nil
        else { return }
        tracker = Tracker(id: UUID().uuidString,
                          name: nameTracker,
                          color: selectedColor,
                          emoji: selectedEmoji,
                          schedule: engSchedule,
                          isPinned: false,
                          type: trackerType)
        guard let tracker else { return }
        trackerDataService.addTracker(category: category, tracker: tracker)
        delegate?.dismissViewController(self)
    }
    
    func cancelCreation() {
        dismiss(animated: true)
    }
    
    func textFieldDidChanged(text: String) -> Bool {
        return text.count >= 38 ? false : true
    }
}
//MARK: - ChooseScheduleViewControllerDelegate
extension CreateTrackerViewController: ChooseScheduleViewControllerDelegate {
    func getSchedule(selectedDays: [WeekDay] ) {
        engSchedule = selectedDays.map {$0.engString}
        let daysString = selectedDays.map{$0.shortString}
        schedule = daysString
        setSchedule(schedule: schedule)
    }
}
//MARK: - CategoriesViewControllerDelegate
extension CreateTrackerViewController: CategoriesViewModelDelegate {
    func getCategory(with name: String) {
        category = name
        setCategory(category: name)
    }
}

//MARK: - UITableViewDataSource
extension CreateTrackerViewController: UITableViewDataSource {
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
    
    
}
//MARK: - UITableViewDelegate
extension CreateTrackerViewController: UITableViewDelegate {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: - UICollectionViewDataSource
extension CreateTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return emojies.count
        case 1:
            return  colors.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.identifier,
                for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            cell.config(emoji: emojies[safe: indexPath.row])
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.identifier,
                for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            cell.config(color: colors[safe: indexPath.row])
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
extension CreateTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = trackerView.bounds
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
        let width = trackerView.bounds.width
        let height = trackerView.bounds.height / 9
        
        return CGSize(width: width, height: height)
    }
}

extension CreateTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        selectedItem = indexPath
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            cell?.isCellSelected  = true
            emojiSelectedItem = indexPath.item
            guard let emojiSelectedItem else { return }
            selectedEmoji = emojies[safe: emojiSelectedItem]
            
        case 1:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            cell?.isCellSelected  = true
            colorSelectedItem = indexPath.item
            guard let colorSelectedItem else { return }
            selectedColor = colors[safe: colorSelectedItem]
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        guard let section = selectedItem?.section else { return }
        switch section {
        case 0:
            guard let item = emojiSelectedItem,
                  let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? EmojiCollectionViewCell
            else { return }
            cell.isCellSelected = false
        case 1:
            guard let item = colorSelectedItem,
                  let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? ColorCollectionViewCell
            else { return }
            cell.isCellSelected = false
        default: break
        }
    }
}


