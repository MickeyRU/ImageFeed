//
//  ImageListServiceStub.swift
//  ImageFeedTests
//
//  Created by Павел Афанасьев on 05.06.2023.
//

import Foundation
@testable import ImageFeed

final class ImageListServiceStub: ImageListServiceProtocol {
    static let imageListDidChangeNotification = Notification.Name(ImagesListService.didChangeNotification.rawValue)
    var photos: [ImageFeed.Photo] = []
    
    func fetchPhotosNextPage() {
        photos = [
            ImageFeed.Photo(id: "1", size: CGSize(width: 30, height: 30), createdAt: nil, welcomeDescription: "welcome1", thumbImageURL: "", largeImageURL: "", isLiked: false),
            ImageFeed.Photo(id: "2", size: CGSize(width: 30, height: 30), createdAt: nil, welcomeDescription: "welcome2", thumbImageURL: "", largeImageURL: "", isLiked: false),
            ImageFeed.Photo(id: "3", size: CGSize(width: 30, height: 30), createdAt: nil, welcomeDescription: "welcome3", thumbImageURL: "", largeImageURL: "", isLiked: false),
        ]
        
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification,
                                        object: self,
                                        userInfo: ["Photos": self.photos])
    }
    
    func changeLike(photoID: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
    }
}
