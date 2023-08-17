import UIKit

final class TabBarController: UITabBarController {
    
    private enum TabBarItems {
        case tracker
        case statistics
        
        var title: String {
            switch self {
            case .tracker:
                return NSLocalizedString("Trackers", comment: "")
            case .statistics:
                return NSLocalizedString("Statistics", comment: "")
            }
        }
        
        var image: UIImage? {
            switch self {
            case .tracker:
                return UIImage(named: "record.circle")
            case .statistics:
                return UIImage(named: "hare")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let tabBarItems: [TabBarItems] = [.tracker, .statistics]
        tabBar.tintColor = .ypBlue
        tabBar.unselectedItemTintColor = .ypGray
        tabBar.backgroundColor = .ypDayNight
        
        viewControllers = tabBarItems.map({ item in
            switch item {
            case .tracker:
                let viewController = TrackersViewController()
                return createNavigationController(vc: viewController, title: item.title)
            case .statistics:
                let viewController = StatisticsViewController()
                return createNavigationController(vc: viewController, title: item.title)
            }
        })
        
        viewControllers?.enumerated().forEach({ (index, vc) in
            vc.tabBarItem.title = tabBarItems[index].title
            vc.tabBarItem.image = tabBarItems[index].image
        })
    }
    
    private func createNavigationController(vc: UIViewController, title: String) -> UINavigationController {
        vc.title = title
        let navigationVC = UINavigationController(rootViewController: vc)
        navigationVC.navigationItem.largeTitleDisplayMode = .always
        navigationVC.navigationBar.prefersLargeTitles = true
        return navigationVC
    }
}
