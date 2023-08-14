//
//  FilterTrackersViewController.swift
//  Tracker
//
//  Created by D on 14.08.2023.
//

import UIKit

protocol FilterTrackersViewControllerDelegate: AnyObject {
    func sendFilterType(_ type: FilterTypes)
}


final class FilterTrackersViewController: UIViewController {
    private var filtersView: FilterTrackersView!

    weak var delegate: FilterTrackersViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Filters", comment: "")
        filtersView = FilterTrackersView()
        filtersView.setupTableView(dataSource: self, delegate: self)
        setupView()
    }
    private var selectedIndex: IndexPath?

    private let filters: [FilterTypes] = FilterTypes.allCases

    private func setupView() {
        view.backgroundColor = UIColor.systemBackground
        view.addSubview(filtersView)
        NSLayoutConstraint.activate([
            filtersView.topAnchor.constraint(equalTo: view.topAnchor),
            filtersView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filtersView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension FilterTrackersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FilterCell else { return }
        cell.isSelectedCell.toggle()
        delegate?.sendFilterType(filters[safe: indexPath.row] ?? .allTrackers)
        dismiss(animated: true)
    }
}

extension FilterTrackersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.identifier) as? FilterCell
        else { return FilterCell() }
        let filter = filters[indexPath.row]
        cell.configCell(filter: filter.string, isSelected: false)
        return cell
    }


}
