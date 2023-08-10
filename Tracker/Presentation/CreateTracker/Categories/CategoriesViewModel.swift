//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by D on 10.08.2023.
//

import Foundation

protocol CategoriesViewModelDelegate: AnyObject {
    func getCategory(with: String)
}

final class CategoriesViewModel {
    
    @Observable
    private(set) var categories: [String]?
    
    private let trackersDataService = TrackersDataService.shared
    
    weak var delegate: CategoriesViewModelDelegate?
    
    init() {
        fetchCategories()
    }
    
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
    
    private func fetchCategories() {
        categories = trackersDataService.fetchAllCategoires()
    }
}

extension CategoriesViewModel: AddCategoryViewControllerDelegate {
    func sendCategory(category: String) {
        if !(categories?.contains(category) ?? false) {
            trackersDataService.addCategory(category: category)
            categories?.append(category)
        }
    }

}
