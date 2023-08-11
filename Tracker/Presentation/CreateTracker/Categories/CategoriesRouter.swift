//
//  CategoriesRouter.swift
//  Tracker
//
//  Created by D on 10.08.2023.
//

import UIKit

protocol CategoriesRoutingLogic {
    func navigateToAddCategory(editingType: EditingType,
                               viewModel: CategoriesViewModel,
                               word: String,
                               viewController: UIViewController)
}

final class CategoriesRouter {
    weak var viewController: UIViewController?
    
    deinit {
        print("deinited router")
    }
}

extension CategoriesRouter: CategoriesRoutingLogic {
    func navigateToAddCategory(editingType: EditingType,
                               viewModel: CategoriesViewModel,
                               word: String,
                               viewController: UIViewController) {
        let vc = AddCategoryViewController()
        vc.delegate = viewModel
        vc.editingType = editingType
        vc.wordToEdit = word
        let nvc = UINavigationController(rootViewController: vc)
        viewController.present(nvc, animated: true)
    }
}
