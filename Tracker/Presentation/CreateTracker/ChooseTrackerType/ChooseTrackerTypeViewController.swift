import UIKit

enum TrackerType {
    case habit
    case irregularEvent

    var toString: String {
        switch self {
        case .habit: return "habit"
        case .irregularEvent: return "event"
        }
    }
}

protocol ChooseTypeTrackerViewControllerDelegate: AnyObject {
    func dimissVC(_ viewcontroller: UIViewController)
    func shouldUpdateTrackers()
}

final class ChooseTypeTrackerViewController: UIViewController {
    
    weak var delegate: ChooseTypeTrackerViewControllerDelegate?
    
    private var chooseTrackerTypeView: ChooseTrackerTypeView!
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        chooseTrackerTypeView = ChooseTrackerTypeView(frame: .zero, delegate: self)
        setupView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.shouldUpdateTrackers()
    }
    
    //MARK: - Setup view
    private func setupView() {
        title = "Создание трекера"
        view.addSubview(chooseTrackerTypeView)
        NSLayoutConstraint.activate([
            chooseTrackerTypeView.topAnchor.constraint(equalTo: view.topAnchor),
            chooseTrackerTypeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chooseTrackerTypeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            chooseTrackerTypeView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func createTrackerViewController(trackerType: TrackerType) -> UINavigationController {
        let vc = CreateTrackerViewController()
        vc.trackerType = trackerType
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        return nvc
    }
}
//MARK: - ChooseTrackerTypeViewDelegate
extension ChooseTypeTrackerViewController: ChooseTrackerTypeViewDelegate {
    func showHabitCreaterVC() {
        let vc = createTrackerViewController(trackerType: .habit)
        present(vc, animated: true)
    }
    
    func showIrregularCreaterVC() {
        let vc = createTrackerViewController(trackerType: .irregularEvent)
        present(vc, animated: true)
    }
}
//MARK: - CreateTrackerViewControllerDelegate
extension ChooseTypeTrackerViewController: CreateTrackerViewControllerDelegate {
    func dismissViewController(_ viewController: UIViewController) {
        delegate?.dimissVC(viewController)
    }
    
    func makeTrackerCategory(_ trackerCategory: TrackerCategory?) {
    }
    
}
