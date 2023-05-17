//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 30.03.2023.
//

import UIKit
import Kingfisher
import WebKit

final class ProfileViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
        
    // MARK: - Private Properties
    
    private let profileImageService = ProfileImageService.shared
    private let alertPresenter = AlertPresenter()
    
    private let profileImage : UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 61
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .white
        return label
    }()
    
    private var loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13)
        label.textColor = Colors.accountNameLabel
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private let exitButton: UIButton = {
        let button = UIButton()
        button.setImage(Images.exitButtonImage, for: .normal)
        button.addTarget(self, action: #selector(didTappedExitButton), for: .touchUpInside)
        return button
    }()
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    @objc private func didTappedExitButton() {
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.logOutFromProfile()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .default)
        
        alertPresenter.prepeareAlertForExit(
            alertTitle: "Пока, пока!",
            alertMessage:"Уверены, что хотите выйти?",
            alertActions: [yesAction, noAction])
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        alertPresenter.delegate = self
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ){ [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = ProfileService.shared.profile else { return }
        updateProfileUIData(profile: profile)
    }
        
    // MARK: - Private Methods
    
    private func setupViews() {
        [profileImage, nameLabel, loginNameLabel, descriptionLabel, exitButton].forEach { view.addViews($0) }
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor, multiplier: 1.0),
            
            nameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            nameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: loginNameLabel.leadingAnchor),
            descriptionLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            exitButton.widthAnchor.constraint(equalToConstant: 20),
            exitButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    private func updateAvatar() {
        guard
            let profileImageURl = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURl)
        else { return }
        profileImage.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profileImage.kf.setImage(with: url, options: [.processor(processor)])
    }
}

extension ProfileViewController {
    func updateProfileUIData(profile: Profile) {
        DispatchQueue.main.async { // Обновляем UI в главном асинхронном потоке
            self.nameLabel.text = profile.name
            self.descriptionLabel.text = profile.bio
            self.loginNameLabel.text = profile.loginName
        }
    }
}

extension ProfileViewController {
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
}

extension ProfileViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController) {
        present(alert, animated: true)
    }
}
