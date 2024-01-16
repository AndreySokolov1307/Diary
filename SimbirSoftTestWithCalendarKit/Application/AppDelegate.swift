//
//  AppDelegate.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 10.01.2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.backgroundColor = .white
        let rootViewController = CalendarViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

}

