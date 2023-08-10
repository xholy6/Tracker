//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by D on 12.06.2023.
//

import UIKit

protocol AddCategoryViewControllerDelegate: AnyObject {
    func sendCategory(category: String)
}

final class AddCategoryViewController: UIViewController {
    
    weak var delegate: AddCategoryViewControllerDelegate?
    
    private var addCategoryView: AddCategoryView!
    private var category: String!
    
    var editingType: EditingType!
    var wordToEdit: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCategoryView = AddCategoryView(frame: .zero, delegate: self)
        setupView()
    }
    
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

extension AddCategoryViewController: AddCategoryViewDelegate {
    func confirmNewCategory(with text: String) {
        category = text
    }

    func dismissVC() {
        delegate?.sendCategory(category: category)
        dismiss(animated: true)
    }
}
