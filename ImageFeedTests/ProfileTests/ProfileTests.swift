//
//  ProfileTests.swift
//  ImageFeedTests
//
//  Created by Павел Афанасьев on 30.05.2023.
//

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //given
        let viewController = ProfileViewController()
        let profileService = ProfileService()
        let presenter = ProfilePresenterSpy(profileService: profileService)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled) //behaviour verification
    }
    
    func testGetUrlForProfileImage() {
        //given
        let profileService = ProfileService()
        let presenter = ProfilePresenterSpy(profileService: profileService)
        
        //when
        let url = presenter.getUrlForProfileImage()?.absoluteString
        
        //then
        XCTAssertEqual(url, APIConstants.baseURLString) //return value verification
    }
    
    func testUpdateAvatar() {
        //given
        let profileService = ProfileService()
        let presenter = ProfilePresenterSpy(profileService: profileService)
        let viewController = ProfileViewControllerSpy(presenter: presenter)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.updateAvatar()
        
        //then
        XCTAssertTrue(viewController.updateChanged) //behaviour verification
    }
    
    func testShowLogoutAlert() {
        //given
        let profileService = ProfileService()
        let presenter = ProfilePresenterSpy(profileService: profileService)
        let viewController = ProfileViewControllerSpy(presenter: presenter)
        viewController.presenter = presenter
        presenter.view = viewController
        
        //when
        viewController.showLogOutAlert()
        
        //then
        XCTAssertTrue(presenter.isAlertShowed) //behaviour verification
    }
}
