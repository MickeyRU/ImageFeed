//
//  ImagesStructures.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 14.05.2023.
//

import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct PhotosResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let isLiked: Bool
    var createdAt: String?
    var description: String?
    var urls: UrlsResult
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, urls
        case createdAt = "created_at"
        case isLiked = "liked_by_user"
    }
}

struct UrlsResult: Codable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct LikePhotoResult: Codable {
    let photo: PhotosResult?
}
