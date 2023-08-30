//
//  Observable.swift
//  Tracker
//
//  Created by D on 10.08.2023.
//

import Foundation

@propertyWrapper
final class Observable<Value> {
    
    private var onChange: ((Value) -> Void)?
    
    var wrappedValue: Value {
        didSet {
            onChange?(wrappedValue)
        }
    }
    
    var projectedValue: Observable<Value> {
        return self
    }
    
    init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }
    
    func bind(action: @escaping ((Value) -> Void) ) {
        self.onChange = action
    }
}
