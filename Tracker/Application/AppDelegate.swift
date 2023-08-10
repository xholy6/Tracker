//
//  AppDelegate.swift
//  Tracker
//
//  Created by D on 25.04.2023.
//

import UIKit
import CoreData

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    private lazy var persistentContainer: NSPersistentContainer? = {
        let containerCreater = PersistentContainerCreater()
        let container = try? containerCreater.persistentContainer()
        return container
    }()
    
    lazy var trackerDataStore: TrackerDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerDataStore = TrackerDataStore(context: container.viewContext)
        return trackerDataStore
    }()
    
    lazy var trackerCategoryDataStore: TrackerCategoryDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerCategoryDataStore = TrackerCategoryDataStore(context: container.viewContext)
        return trackerCategoryDataStore
    }()
    
    lazy var trackerRecordDataStore: TrackerRecordDataStore? = {
        guard let container = self.persistentContainer else { return nil }
        let trackerRecordDataStore = TrackerRecordDataStore(context: container.viewContext)
        return trackerRecordDataStore
    }()


}

