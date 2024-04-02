//
//  AppDelegate.swift
//  SlimBody
//
//  Created by Anastasia Kravchenko on 22.09.2023.
//

import UIKit
import SwiftyBeaver

let log = SwiftyBeaver.self

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootCoordinator: RootCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let console = ConsoleDestination()
        log.addDestination(console)

        window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController = UINavigationController()
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        window?.overrideUserInterfaceStyle = .light

        rootCoordinator = RootCoordinator(navigationController: navigationController)
        rootCoordinator?.start()

        return true
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

}
