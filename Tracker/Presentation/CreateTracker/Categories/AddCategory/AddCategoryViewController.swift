//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by D on 12.06.2023.
//

import UIKit

protocol AddCategoryViewControllerDelegate: AnyObject {
    func sendCategory(category: String)
    func reloadData()
}

final class AddCategoryViewController: UIViewController {
    
    weak var delegate: AddCategoryViewControllerDelegate?
    
    private let trackersDataService = TrackersDataService.shared
    
    private struct AddCategoryViewControllerConstants {
        static let addTitle = "Новая категория"
        static let editTitle = "Редактирование категории"
    }
    
    private var addCategoryView: AddCategoryView!
    private var category: String!
    
    var editingType: EditingType!
    var wordToEdit: String!
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addCategoryView = AddCategoryView(frame: .zero, delegate: self, editType: editingType, word: wordToEdit)
        switch editingType {
        case .add:
            title = AddCategoryViewControllerConstants.addTitle
        default:
            title =  AddCategoryViewControllerConstants.editTitle
        }
        setupView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.reloadData()
    }
    //MARK: - Setup view
    private func setupView() {
        view.addSubview(addCategoryView)
        
        NSLayoutConstraint.activate([
            addCategoryView.topAnchor.constraint(equalTo: view.topAnchor),
            addCategoryView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addCategoryView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addCategoryView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
}
//MARK: - AddCategoryViewDelegate
extension AddCategoryViewController: AddCategoryViewDelegate {
    func confirmNewCategory(with text: String) {
        category = text
    }

    func dismissAddingCategoryVC() {
        delegate?.sendCategory(category: category)
        dismiss(animated: true)
    }
    
    func dismissEditinCategoryVC() {
        trackersDataService.updateCategory(oldTitle: wordToEdit, newTitle: category)
        dismiss(animated: true)
    }
}
