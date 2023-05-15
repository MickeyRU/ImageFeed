//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 14.05.2023.
//

import UIKit

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var currentTask: URLSessionTask?
    
    private let networkClient = NetworkClient.shared
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter
    }()
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        if currentTask != nil {
            return
        }
        
        let nextPage = lastLoadedPage == nil ? 1 : lastLoadedPage! + 1
        
        guard
            let request = imageListRequest(page: nextPage) else {
            assertionFailure("Error with image List Request")
            return
        }
        
        let task = networkClient.getObject(dataType: [PhotosResult].self, for: request) { result in
            switch result {
            case .success(let photoResult):
                self.addNewPhotos(from: photoResult)
            case .failure(let error):
                print(error.localizedDescription)
                // ToDo: Error - вывести уведомление для пользователя?
            }
            self.currentTask = nil
            self.lastLoadedPage = nextPage
        }
        currentTask = task
        task.resume()
    }
    
    private func imageListRequest(page: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)",
            httpMethod: "GET",
            uRLString: Constants.defaultApiBaseURLString)
    }
    
    private func addNewPhotos(from receivedPhotos: [PhotosResult]) {
        receivedPhotos.forEach { photoResult in
            let convertedPhoto = convertToUIPhotoModel(from: photoResult)
            photos.append(convertedPhoto)
            
            NotificationCenter.default.post(
                name: ImagesListService.didChangeNotification,
                object: self,
                userInfo: ["Photos" : self.photos])
        }
    }
    
    private func convertToUIPhotoModel(from photo: PhotosResult) -> Photo {
        return Photo(
            id: photo.id,
            size: CGSize(width: Double(photo.width), height: Double(photo.height)),
            createdAt: photo.createdAt != nil ? dateFormatter.date(from: photo.createdAt!) : nil,
            welcomeDescription: photo.description ?? "",
            thumbImageURL: photo.urls.thumb,
            largeImageURL: photo.urls.full,
            isLiked: photo.isLiked)
    }
}
