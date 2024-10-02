//
//  AppDelegate.swift
//  image-grayscale
//
//  Created by komachi16 on 2024/09/29.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: CameraViewController())
        window?.makeKeyAndVisible()

        return true
    }
}
