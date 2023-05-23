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

    private let dateFormatter: ISO8601DateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
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
                // ToDo: Error - вывести уведомление для пользователя?!
            }
            self.currentTask = nil
            self.lastLoadedPage = nextPage
        }
        currentTask = task
        task.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        currentTask?.cancel()
        guard let request = isLike ? likeRequest(photoID: photoId) : unLikeRequest(photoID: photoId) else {
            assertionFailure("Bad like request")
            return
        }
        let task = networkClient.getObject(dataType: LikePhotoResult.self, for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let PhotoResult):
                if let currentPhotoIndex = self.photos.firstIndex(where: { $0.id == PhotoResult.photo?.id }) {
                    let currentPhoto = self.photos[currentPhotoIndex]
                    let newPhoto = Photo(
                        id: currentPhoto.id,
                        size: currentPhoto.size,
                        createdAt: currentPhoto.createdAt,
                        welcomeDescription: currentPhoto.welcomeDescription,
                        thumbImageURL: currentPhoto.thumbImageURL,
                        largeImageURL: currentPhoto.largeImageURL,
                        isLiked: !currentPhoto.isLiked
                    )
                    self.photos = self.photos.withReplaced(itemAt: currentPhotoIndex, newValue: newPhoto)
                }
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        currentTask = task
        task.resume()
    }
    
    private func addNewPhotos(from receivedPhotos: [PhotosResult]) {
        receivedPhotos.forEach { photoResult in
            let convertedPhoto = convertToUIPhotoModel(from: photoResult)
            photos.append(convertedPhoto)
        }
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self,
            userInfo: ["Photos" : self.photos])
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

// MARK: Request Methods

extension ImagesListService {
    
    private func imageListRequest(page: Int) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos"
            + "?page=\(page)",
            httpMethod: "GET",
            uRLString: Constants.defaultApiBaseURLString)
    }
    
    private func likeRequest(photoID: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoID)/like",
            httpMethod: "POST",
            uRLString: Constants.defaultApiBaseURLString)
    }
    
    private func unLikeRequest(photoID: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(
            path: "/photos/\(photoID)/like",
            httpMethod: "DELETE",
            uRLString: Constants.defaultApiBaseURLString)
    }
}
