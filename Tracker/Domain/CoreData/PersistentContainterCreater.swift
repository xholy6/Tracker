//
//  PersistentContainterCreater.swift
//  Tracker
//
//  Created by D on 03.08.2023.
//

import Foundation
import CoreData

final class PersistentContainerCreater {
    private let modelName = "Model"
    func persistentContainer() throws -> NSPersistentContainer {
        let container = NSPersistentContainer(name: modelName)

        var loadError: Error?
        container.loadPersistentStores { description, error in
            if error != nil {
                assertionFailure("Some persistent container error")
                loadError = error
            }
        }

        try loadError.map { throw $0 }

        return container
    }
}
