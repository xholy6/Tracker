import UIKit

protocol ChooseScheduleViewControllerDelegate: AnyObject {
    func getSchedule(selectedDays: [WeekDay])
}

final class ChooseScheduleViewController: UIViewController {
    
    weak var delegate: ChooseScheduleViewControllerDelegate?
    
    private var scheduleView: ChooseScheduleView!
    private var weekDays: [WeekDay] = WeekDay.allCases
    private (set) var selectedDays: [WeekDay] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduleView = ChooseScheduleView(frame: view.bounds, delegate: self)
        scheduleView.setupScheduleTableView(delegate: self, dataSource: self)
        setupView()
        title = "Расписание"
    }
    
    private func setupView() {
        view.addSubview(scheduleView)
        
        NSLayoutConstraint.activate([
            scheduleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scheduleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scheduleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scheduleView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
extension ChooseScheduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.indexPath = indexPath
        let dayText = weekDays[indexPath.row].fullString
        cell.configCell(dayText: dayText)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
}

extension ChooseScheduleViewController: UITableViewDelegate {
    
}
//MARK: - ChooseScheduleViewDelegate
extension ChooseScheduleViewController: ChooseScheduleViewDelegate {
    func setSchedule() {
        delegate?.getSchedule(selectedDays: selectedDays)
        dismiss(animated: true)
    }
}

extension ChooseScheduleViewController: ScheduleCellDelegate {
    func getSelectedDay(_ cell: ScheduleCell, selected: Bool) {
        let selectedDay: WeekDay
        guard let cellIndex = cell.indexPath?.row else { return }
        selectedDay = weekDays[cellIndex]
        if selected {
            selectedDays.append(selectedDay)
        } else {
            guard let deleteIndex = selectedDays.firstIndex(where: {$0 == selectedDay}) else { return }
            selectedDays.remove(at: deleteIndex)
        }
    }
}
