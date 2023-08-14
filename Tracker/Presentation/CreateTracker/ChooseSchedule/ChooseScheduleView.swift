import UIKit

protocol ChooseScheduleViewDelegate: AnyObject {
    func setSchedule()
}

final class ChooseScheduleView: UIView {
    
    weak var delegate: ChooseScheduleViewDelegate?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.layer.cornerRadius = 16
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.ypMedium16
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonDidTapped), for: .touchUpInside)
        return button
    }()
    
    init(frame: CGRect, delegate: ChooseScheduleViewDelegate?) {
        self.delegate = delegate
        super.init(frame: frame)
        backgroundColor = .white
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubViews(tableView, doneButton)
        
    }
    
    private func activateConstraints() {
        let edge: CGFloat = 20
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 75*7),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),

            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            doneButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            doneButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])

    }
    
    @objc
    private func doneButtonDidTapped() {
        delegate?.setSchedule()
    }
}

extension ChooseScheduleView {
    func setupScheduleTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }
}
