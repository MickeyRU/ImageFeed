//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 30.03.2023.
//

import UIKit

final class ProfileViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
        
    // MARK: - Private Properties
    
    private let profileImage : UIImageView = {
        let imageView = UIImageView(image: Images.defaultProfileImage)
        imageView.layer.cornerRadius = 61
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = .boldSystemFont(ofSize: 23)
        label.textColor = .white
        return label
    }()
    
    private let accountNameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = .systemFont(ofSize: 13)
        label.textColor = Colors.accountNameLabel
        return label
    }()
    
    private let statusLabel: UILabel = {
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
    
    @objc private func didTappedExitButton() {
        // ToDo: code
        print("didTappedExitButton")
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
    }
        
    // MARK: - Private Methods
    
    private func layout() {
        [profileImage, userNameLabel, accountNameLabel, statusLabel, exitButton].forEach { view.addViews($0) }
        
        NSLayoutConstraint.activate([
            profileImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 76),
            profileImage.widthAnchor.constraint(equalToConstant: 70),
            profileImage.heightAnchor.constraint(equalTo: profileImage.widthAnchor, multiplier: 1.0),
            
            userNameLabel.topAnchor.constraint(equalTo: profileImage.bottomAnchor, constant: 8),
            userNameLabel.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            userNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            accountNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 8),
            accountNameLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor),
            accountNameLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            statusLabel.topAnchor.constraint(equalTo: accountNameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: accountNameLabel.leadingAnchor),
            statusLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
            
            exitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -26),
            exitButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            exitButton.widthAnchor.constraint(equalToConstant: 20),
            exitButton.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
}
