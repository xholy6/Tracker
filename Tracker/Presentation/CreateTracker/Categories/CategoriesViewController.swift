//import UIKit
//
//protocol CategoriesViewControllerDelegate: AnyObject {
//    func getCategory(with: String)
//}
//
//final class CategoriesViewController: UIViewController {
//
//    weak var delegate: CategoriesViewControllerDelegate?
//
//    private(set) var categories = CategoryStorage.shared.category
//
//    private var categoriesView: CategoriesView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        categoriesView = CategoriesView(frame: view.bounds, delegate: self)
//        categoriesView.setupTableView(delegate: self, dataSource: self)
//        title = "Категория"
//        setupView()
//    }
//
//    private func setupView() {
//        view.addSubview(categoriesView)
//        NSLayoutConstraint.activate([
//            categoriesView.topAnchor.constraint(equalTo: view.topAnchor),
//            categoriesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            categoriesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            categoriesView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//        ])
//    }
//}
//
//extension CategoriesViewController: CategoriesViewDelegate {
//
//    func checkForEmptyCategories() -> Bool {
//        let isCategoriesEmpty = categories.isEmpty
//        return isCategoriesEmpty
//   }
//
//    func presentAddCategoryVC() {
//        let vc = AddCategoryViewController()
//        vc.delegate = self
//        let nvc = UINavigationController(rootViewController: vc)
//        present(nvc, animated: true)
//    }
//}
//
//extension CategoriesViewController: AddCategoryViewControllerDelegate {
//    func sendCategory(category: String) {
//        categories.append(category)
//        CategoryStorage.shared.category = categories
//        categoriesView.needToShowPlug()
//        categoriesView.refreshTableView()
//    }
//}
//
//extension CategoriesViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        categories.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesCell.identifier, for: indexPath) as? CategoriesCell else { return UITableViewCell() }
//
//        cell.configCell(categoryName: categories[indexPath.row] ?? "")
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        75
//    }
//
//
//}
//
//extension CategoriesViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        delegate?.getCategory(with: categories[indexPath.row] ?? "")
//        dismiss(animated: true)
//    }
//}
//
