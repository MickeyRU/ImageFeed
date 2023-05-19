//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 19.04.2023.
//

import UIKit

final class SplashViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Properties
    private let profileService: ProfileService
    private let profileImageService: ProfileImageService
    private let authService: OAuth2Service
    
    private let showLoginFlowSegueIdentifier = "ShowLoginFlow"
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.authorizationLogo
        return imageView
    }()
    
    
    // MARK: - Initializers
    init(profileService: ProfileService = ProfileService.shared,
         profileImageService: ProfileImageService = ProfileImageService.shared,
         authService: OAuth2Service = OAuth2Service.shared) {
        self.profileService = profileService
        self.authService = authService
        self.profileImageService = profileImageService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkAuthStatus()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.backgroundColor = Colors.logoViewBGColor
        view.addViews(backgroundImage)
        
        NSLayoutConstraint.activate([
            backgroundImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            backgroundImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backgroundImage.heightAnchor.constraint(equalToConstant: 75),
            backgroundImage.widthAnchor.constraint(equalToConstant: 78)
        ])
    }
    
    private func checkAuthStatus() {
        if let token = OAuth2TokenStorage().token {
            self.fetchProfile(token: token)
        } else {
            let viewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "AuthViewControllerID")
            guard let authViewController = viewController as? AuthViewController else { return }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
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
        authService.fetchAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let token):
                self.fetchProfile(token: token)
            case .failure(let error):
                self.showAlert(with: error)
                break
            }
        }
    }
    
    private func fetchProfile(token: String) {
        profileService.fetchProfile(token) { [weak self] profileResult in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            switch profileResult {
            case .success(let result):
                let profile = self.profileService.convertProfile(profile: result)
                let username = profile.username
                self.profileImageService.fetchProfileImageURL(userName: username) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                self.showAlert(with: error)
                break
            }
        }
    }
    
    private func showAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так :(",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}
