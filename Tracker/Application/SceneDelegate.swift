//
//  SceneDelegate.swift
//  Tracker
//
//  Created by D on 25.04.2023.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = decideToCreateVC()
        window?.makeKeyAndVisible()
    }
    
    private func decideToCreateVC() -> UIViewController {
        let isLaunchExists = UserDefaults.standard.bool(forKey: "isFirstAppLaunch")
        let controller = isLaunchExists ? TabBarController() : OnboardingPageViewController()
        return controller
    }
}

