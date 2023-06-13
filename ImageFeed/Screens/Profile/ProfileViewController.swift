//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 30.03.2023.
//

import UIKit
import Kingfisher
import WebKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol { get set }
    func updateAvatar()
    func showLogOutAlert()
}

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    lazy var presenter: ProfilePresenterProtocol = {
        return ProfilePresenter()
    }()
    
    // MARK: - Private Properties
        
    private var profileImage : UIImageView = {
        let imageView = UIImageView()
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
        button.accessibilityIdentifier = "logoutButton"
        return button
    }()
    
    @objc private func didTappedExitButton() {
        showLogOutAlert()
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.viewDidLoad()
        setupViews()
        updateAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let profile = presenter.profileService.profile else { return }
        updateProfileUIData(profile: profile)
    }
    
    // MARK: - Private Methods
    
    private func setupViews() {
        view.backgroundColor = Colors.logoViewBGColor
        
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
            
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 89),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    func showLogOutAlert() {
        let alert = presenter.createAlert()
        present(alert, animated: true, completion: nil)
    }
    
    func updateAvatar() {
        guard let url = presenter.getUrlForProfileImage() else { return }
        let processor = RoundCornerImageProcessor(cornerRadius: 61)
        profileImage.kf.indicatorType = .activity
        profileImage.kf.setImage(with: url, placeholder: Images.profilePhotoStub, options: [.processor(processor)])
        
        let cache = ImageCache.default
        cache.clearDiskCache()
        cache.clearMemoryCache()
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
