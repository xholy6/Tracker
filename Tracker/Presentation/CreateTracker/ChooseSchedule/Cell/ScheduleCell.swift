import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func getSelectedDay(_ cell: ScheduleCell, selected: Bool)
}

final class ScheduleCell: UITableViewCell {
    
    static let identifier = "scheduleCell"
    
    weak var delegate: ScheduleCellDelegate?
    
    var indexPath: IndexPath?
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.ypRegular17
        return label
    }()
    
    private lazy var switchView: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = .ypBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        return switchView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear
        contentView.backgroundColor = .ypLightGray
        contentView.addSubViews(dayLabel,
                                switchView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            switchView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switchView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
//            switchView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.25)

        ])
    }
    
    func configCell(dayText: String) {
        dayLabel.text = dayText
    }
    
    @objc
    private func switchChanged(_ sender: UISwitch) {
        delegate?.getSelectedDay(self, selected: sender.isOn)
    }
}
