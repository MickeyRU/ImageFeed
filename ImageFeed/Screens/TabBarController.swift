//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 12.05.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController
        let imageListPresenter = ImagesListPresenter(imageListService: ImagesListService.shared)
        imagesListViewController.configure(imageListPresenter)
        imagesListViewController.tabBarItem = UITabBarItem(title: nil,
                                                           image: Images.imageListTabBarIcon,
                                                           selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: nil,
                                                        image: Images.profileTabBarIcon,
                                                        selectedImage: nil)
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
