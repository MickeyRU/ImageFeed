//
//  ProfileStructures.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 03.05.2023.
//

import Foundation

struct ProfileResult: Codable {
    let userLogin: String
    let firstName: String?
    let lastName: String?
    let bio: String?
    let profileImage: ProfileImage?
    
    private enum CodingKeys: String, CodingKey {
        case userLogin = "username"
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
        case profileImage = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName : String
    let bio: String?
}
