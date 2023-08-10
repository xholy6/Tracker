//
//  CategoriesVC.swift
//  Tracker
//
//  Created by D on 10.08.2023.
//

import UIKit

enum EditingType {
    case add
    case edit
}

final class CategoriesVC: UIViewController {
    
    private var viewModel: CategoriesViewModel?
    
    private struct AddCategoryConstants {
        static let addButtontitle = "Добавить категорию"
        static let actionSheetTitle = "Эта категория точно не нужна?"
        static let plugLabelText = """
        Привычки и события можно
        объединить по смыслу
    """
    }
    
    var viewModelDelegate: CategoriesViewModelDelegate?
    
    //MARK: - UI objects
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
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CategoriesViewModel()
        viewModel?.delegate = viewModelDelegate
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        showPlugView()
        bind()
        setupView()
        activateConstraints()
    }
    
    //MARK: - Private methods
    @objc
    private func addCategoryButtonTapped() {
        let nvc = showAddCategoryView(editingType: .add)
        present(nvc, animated: true)
    }
    
    private func showAddCategoryView(editingType: EditingType)  -> UINavigationController {
        let vc = AddCategoryViewController()
        vc.delegate = viewModel
        vc.editingType = editingType
        let nvc = UINavigationController(rootViewController: vc)
        return nvc
    }
    
    private func showActionSheet(_ indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil,
                                                message: AddCategoryConstants.actionSheetTitle,
                                                preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить",
                                         style: .destructive) { [weak self] _ in
            self?.viewModel?.deleteCategory(at: indexPath.row)
        }
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func showPlugView() {
        guard let viewModel else { return }
        plugView.isHidden = viewModel.isCategoriesEmpty() ? true : false
    }
    
    private func bind() {
        viewModel?.$categories.bind{ [weak self] _ in
            self?.tableView.reloadData()
            self?.showPlugView()
        }
    }
    
    //MARK: - Setup View
    private func setupView() {
        view.addSubViews(tableView, addCategoryButton)
        view.addSubview(plugView)
    }
    
    private func activateConstraints() {
        let edge: CGFloat = 16
        
        NSLayoutConstraint.activate([
            
            plugView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plugView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            plugView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edge),
            plugView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edge),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: edge),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -edge),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: 40),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
//MARK: - UITableViewDataSource
extension CategoriesVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.categories?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoriesCell.identifier) as? CategoriesCell
        else { return CategoriesCell() }
        guard let category = viewModel?.categories?[indexPath.row] else { return CategoriesCell() }
        cell.configCell(categoryName: category)
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
}
//MARK: - UITableViewDelegate
extension CategoriesVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let number = indexPath.row
        viewModel?.shouldSendSelectedCategory(categoryNumber: number)
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        cell.accessoryType = (cell.accessoryType == .checkmark) ? .none : .checkmark
        dismiss(animated: true)
    }
}

//MARK: - UIContextMenuInteractionDelegate
extension CategoriesVC: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        guard let cell = interaction.view as? CategoriesCell else { return nil }
        guard let indexPath = tableView.indexPath(for: cell) else { return nil }
        
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let action1 = UIAction(title: "Редактировать" ){ [weak self] _ in
                guard let self else { return }
                let nvc = self.showAddCategoryView(editingType: .edit)
                self.present(nvc, animated: true)
            }
            
            let action2 = UIAction(title: "Удалить") { [weak self] _ in
                guard let self else { return }
                self.showActionSheet(indexPath)
            }
            
            return UIMenu(title: "" , children: [action1, action2])
        }
        
        return configuration
    }
    
    
}
