import UIKit

final class StatisticsView: UIView {
    private lazy var statisticsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.reuseIdentifer)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 77, left: 0, bottom: 0, right: 0)
        return tableView
    }()

    private lazy var plugView: PlugView = {
        let view = PlugView(frame: .zero,
                            titleLabel: "Анализировать пока нечего",
                            image: UIImage(named: "plugAnalysis") ?? UIImage() )
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(statisticsTableView)
        addSubview(plugView)
        let edge: CGFloat = 16
        NSLayoutConstraint.activate([
            statisticsTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 24),
            statisticsTableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            statisticsTableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            statisticsTableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            plugView.heightAnchor.constraint(equalToConstant: 80),
            plugView.widthAnchor.constraint(equalToConstant: 80),
            plugView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            plugView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            plugView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

    }
}

extension StatisticsView {
    func setupTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        statisticsTableView.delegate = delegate
        statisticsTableView.dataSource = dataSource
    }

    func refreshTableView() {
        statisticsTableView.reloadData()
    }

    func hideTableView(decision: Bool) {
        statisticsTableView.isHidden = decision
        plugView.isHidden = !decision
    }
}
