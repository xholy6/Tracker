import UIKit

protocol CategoriesViewDelegate: AnyObject {
    func checkForEmptyCategories() -> Bool
    func presentAddCategoryVC()
}

final class CategoriesView: UIView {
    
    weak var delegate: CategoriesViewDelegate?
    
    private struct AddCategoryConstants {
        static let addButtontitle = "Добавить категорию"
        static let plugLabelText = """
            Привычки и события можно
            объединить по смыслу
        """
    }
    
    private lazy var plugView: PlugView = {
        let image = UIImage(named: "plugStar")
        let plugView = PlugView(frame: .zero,
                                titleLabel: AddCategoryConstants.plugLabelText,
                                image: image ?? UIImage() )
        plugView.isHidden = false
        return plugView
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.ypMedium16
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.register(CategoriesCell.self, forCellReuseIdentifier: CategoriesCell.identifier)
        return tableView
    }()

    
     init(frame: CGRect, delegate: CategoriesViewDelegate?) {
        self.delegate  = delegate
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .white
        needToShowPlug()
        setupView()
        activateConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubViews(tableView, addCategoryButton)
        addSubview(plugView)
    }
    
    private func activateConstraints() {
        let edge: CGFloat = 16
        
        NSLayoutConstraint.activate([
            
            plugView.centerXAnchor.constraint(equalTo: centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: centerYAnchor),
            plugView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            plugView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: edge),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -edge),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: 40),

            addCategoryButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func addCategoryButtonTapped() {
        delegate?.presentAddCategoryVC()
    }
    
     func needToShowPlug() {
        guard let delegate = delegate else { return }
        plugView.isHidden = delegate.checkForEmptyCategories() ? false : true
    }
    
    func refreshTableView() {
        tableView.reloadData()
    }
}

extension CategoriesView {
    func setupTableView(delegate: UITableViewDelegate, dataSource: UITableViewDataSource) {
        tableView.delegate = delegate
        tableView.dataSource = dataSource
    }
}
