//
//  ProfilePresenterSpy.swift
//  ImageFeedTests
//
//  Created by Павел Афанасьев on 02.06.2023.
//

import ImageFeed
import UIKit

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    var profileService: ImageFeed.ProfileService
    var viewDidLoadCalled: Bool = false
    var isAlertShowed = false
    var view: ProfileViewControllerProtocol?
    
    init (profileService: ProfileService ) {
        self.profileService = profileService
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func viewWillAppear() {
        
    }
    
    func getUrlForProfileImage() -> URL? {
        return URL(string: "https://unsplash.com")
    }
    
    func createAlert() -> UIAlertController {
        isAlertShowed = true
        return UIAlertController()
    }
}
