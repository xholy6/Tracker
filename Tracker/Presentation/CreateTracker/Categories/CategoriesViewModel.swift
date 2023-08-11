//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by D on 10.08.2023.
//

import UIKit

protocol CategoriesViewModelDelegate: AnyObject {
    func getCategory(with: String)
}

protocol ActionsWithCategoriesProtocol {
    func isCategoriesEmpty() -> Bool
    func shouldSendSelectedCategory(categoryNumber: Int)
    func deleteCategory(at index: Int)
    func selectCategory(at index: Int)
}

final class CategoriesViewModel {
    
    @Observable
    private(set) var categories: [String]?
    
    @Observable
    private(set) var selectedCategoryIndex: Int?
    
    private(set) var router = CategoriesRouter()
    
    private let trackersDataService = TrackersDataService.shared
    
    weak var delegate: CategoriesViewModelDelegate?
    
    
    init() {
        fetchCategories()
    }
    
    func presentNextVC(with type: EditingType, at index: Int?, viewController: UIViewController) {
        guard
            let index else { router.navigateToAddCategory(editingType: type,
                                                          viewModel: self,
                                                          word: "",
                                                          viewController: viewController)
            return
        }
        router.navigateToAddCategory(editingType: type,
                                     viewModel: self,
                                     word: categories?[index] ?? "",
                                     viewController: viewController)
    }
    
    private func fetchCategories() {
        categories = trackersDataService.fetchAllCategoires()
    }
}
//MARK: - ActionsWithCategoriesProtocol
extension CategoriesViewModel: ActionsWithCategoriesProtocol {
    func isCategoriesEmpty() -> Bool{
        guard let categories else { return true }
        return !categories.isEmpty
    }
    
    func shouldSendSelectedCategory(categoryNumber: Int) {
        guard let categories else { return }
        let category = categories[categoryNumber]
        delegate?.getCategory(with: category)
    }
    
    func deleteCategory(at index: Int) {
        guard let categoryName = categories?[index] else { return }
        trackersDataService.deleteCategory(category: categoryName)
        fetchCategories()
    }
    
    func selectCategory(at index: Int) {
        selectedCategoryIndex = (selectedCategoryIndex != index) ? index : nil
    }
}
//MARK: - AddCategoryViewControllerDelegate
extension CategoriesViewModel: AddCategoryViewControllerDelegate {
    func sendCategory(category: String) {
        if !(categories?.contains(category) ?? false) {
            trackersDataService.addCategory(category: category)
            categories?.append(category)
        }
    }
    
    func reloadData() {
        fetchCategories()
    }
}
