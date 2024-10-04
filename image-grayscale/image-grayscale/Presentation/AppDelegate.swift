//
//  AppDelegate.swift
//  image-grayscale
//
//  Created by komachi16 on 2024/09/29.
//

import UIKit
import Photos

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        window?.rootViewController = UINavigationController(rootViewController: CameraViewController())
        window?.makeKeyAndVisible()

        requestPhotoLibraryAccess()

        return true
    }

    private func requestPhotoLibraryAccess() {
        guard PHPhotoLibrary.authorizationStatus() != .authorized else {
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
           guard status != .authorized else { return }
            self?.showPhotoLibraryAccessAlert()
        }
    }

    private func showPhotoLibraryAccessAlert() {
        let alert = UIAlertController(
            title: "写真ライブラリへのアクセス",
            message: "写真ライブラリへのアクセスを許可してください。",
            preferredStyle: .alert
        )
        let settingsAction = UIAlertAction(title: "設定", style: .default) { [weak self] _ in
            self?.openAppSettings()
        }
        let closeAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        alert.addAction(settingsAction)
        alert.addAction(closeAction)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }

    private func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}
