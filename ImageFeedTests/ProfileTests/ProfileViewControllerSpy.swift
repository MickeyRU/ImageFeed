//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Павел Афанасьев on 02.06.2023.
//

import UIKit
import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ImageFeed.ProfilePresenterProtocol
    var updateChanged = false
    
    init (presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    func updateAvatar() {
        updateChanged = true
    }
    
    func showLogOutAlert() {
        presenter.createAlert()
    }

    
}


