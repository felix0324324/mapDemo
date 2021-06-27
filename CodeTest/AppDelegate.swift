//
//  AppDelegate.swift
//  CodeTest
//
//  Created by Alvis on 22/6/2021.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window!.backgroundColor = UIColor.white
        let aNavigationController = UINavigationController(rootViewController: MapViewController())
        aNavigationController.setNavigationBarHidden(true, animated: false)
        window!.rootViewController = aNavigationController
        window!.makeKeyAndVisible()

        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
//        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(MapViewController.self)
        
        return true
    }
}
