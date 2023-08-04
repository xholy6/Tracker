//
//  CategoryStorage.swift
//  Tracker
//
//  Created by D on 14.06.2023.
//

import Foundation

final class CategoryStorage {
    
    static let shared = CategoryStorage()
    
    private init() {}
    
    private enum Keys: String, CodingKey {
        case category = "Category"
    }
    
    private let userDefaults = UserDefaults.standard

    var category: [String?] {
        get {
            userDefaults.stringArray(forKey: Keys.category.rawValue) ?? [String]()
            
        }
        set {
            userDefaults.set(newValue, forKey: Keys.category.rawValue)
        }
    }
}

