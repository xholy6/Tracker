import UIKit

final class StatisticsViewController: UIViewController {

    private var statisticView: StatisticsView!

    private let trackersDataService = TrackersDataService.shared

    private struct StatisticsViewControllerConstants {
        static let best = "Лучший период"
        static let  perfect = "Идеальные дни"
        static let  completed = "Трекеров завершено"
        static let  average = "Среднее значение"
    }

    private var statistics = [StatisticModel]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticView = StatisticsView()
        statisticView.setupTableView(delegate: self, dataSource: self)
        setupView()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeStatistics()
        statisticView.refreshTableView()
        shouldShowPlugView()
    }

    private func setupView() {
        view.addSubview(statisticView)
        view.backgroundColor = .white
        NSLayoutConstraint.activate([
            statisticView.topAnchor.constraint(equalTo: view.topAnchor),
            statisticView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statisticView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makeStatistics() {
        let best = StatisticModel(count: 0, name: StatisticsViewControllerConstants.best)
        let perfect = StatisticModel(count: 0, name: StatisticsViewControllerConstants.perfect)
        let completedCount = trackersDataService.fetchAllCompletedTrackers()
        let completed = StatisticModel(count: completedCount,
                                       name: StatisticsViewControllerConstants.completed)
        let average = StatisticModel(count: 0, name: StatisticsViewControllerConstants.average)
        statistics = [best, perfect, completed, average]
    }

    private func shouldShowPlugView() {
        let allCountsAreZero = statistics.allSatisfy { $0.count == 0 }
        statisticView.hideTableView(decision: allCountsAreZero)
    }
}

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                    withIdentifier: StatisticsCell.reuseIdentifer,
                    for: indexPath) as? StatisticsCell
        else { return UITableViewCell() }
        cell.configCell(text: statistics[indexPath.row].name,
                        count: "\(statistics[indexPath.row].count)")

        return cell
        
    }
}

extension StatisticsViewController: UITableViewDelegate {

}

