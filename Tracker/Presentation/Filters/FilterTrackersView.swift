//
//  FilterTrackersView.swift
//  Tracker
//
//  Created by D on 14.08.2023.
//

import UIKit

final class FilterTrackersView: UIView {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .none
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        return tableView
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
        let edge: CGFloat = 16
        addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            tableView.heightAnchor.constraint(equalToConstant: 75*4)
        ])
    }

}

extension FilterTrackersView {
    func setupTableView(dataSource: UITableViewDataSource, delegate: UITableViewDelegate) {
        tableView.dataSource = dataSource
        tableView.delegate = delegate
    }
}
