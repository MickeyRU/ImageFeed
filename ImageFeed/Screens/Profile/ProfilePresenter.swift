//
//  ProfilePresenter.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 30.05.2023.
//

import Foundation
import WebKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func createAlert() -> UIAlertController
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        configureObserver()
    }
    
    func createAlert() -> UIAlertController {
            let alert = UIAlertController(
                title: "Пока, пока!",
                message: "Уверены, что хотите выйти?",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Да", style: .default, handler: { [weak self] action in
                guard let self = self else { return }
                self.logOutFromProfile()
            }))
            alert.addAction(UIAlertAction(title: "Нет", style: .default, handler: nil))
            alert.dismiss(animated: true)
            return alert
    }
    
    private func configureObserver() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ){ [weak self] _ in
            guard let self = self else { return }
            self.view?.updateAvatar()
        }
    }
    
    private func logOutFromProfile() {
        cleanCookie()
        cleanStorage()
        
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid configuration")
            return
        }
        let splashVC = SplashViewController()
        window.rootViewController = splashVC
    }
    
    private func cleanCookie() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record]) { }
            }
        }
    }
    
    private func cleanStorage() {
        OAuth2TokenStorage.shared.removeToken()
    }
}
