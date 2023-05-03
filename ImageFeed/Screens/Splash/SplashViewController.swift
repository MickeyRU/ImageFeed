//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 19.04.2023.
//

import UIKit
import ProgressHUD

final class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private let showLoginFlowSegueIdentifier = "ShowLoginFlow"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthStatus()
    }
    
    private func checkAuthStatus() {
        if let token = OAuth2TokenStorage().token {
            self.fetchProfile(token: token)
        } else {
            performSegue(withIdentifier: showLoginFlowSegueIdentifier, sender: nil)
        }
    }
    
    private func switchToTabBarController() {
        // Получаем экземпляр `Window` приложения
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        // Cоздаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора.
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Проверим, что переходим на авторизацию
        if segue.identifier == showLoginFlowSegueIdentifier {
            guard
                let viewController = segue.destination as? AuthViewController else { fatalError("Failed to prepare for \(showLoginFlowSegueIdentifier)") }
            // Установим делегатом контроллера наш SplashViewController
            viewController.modalPresentationCapturesStatusBarAppearance = true
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        OAuth2Service.shared.fetchAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success:
                guard let token = OAuth2Service.shared.authToken else { return }
                self.fetchProfile(token: token)
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
    
    // Метод для обновления интерфейса при фетче профайла с сервера
    private func fetchProfile(token: String) {
        ProfileService.shared.fetchProfile(token) { [weak self] profileResult in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch profileResult {
            case .success(let result):
                let profile = ProfileService.shared.convertProfile(profile: result)
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11] Показать ошибку
                break            }
        }
    }
}
