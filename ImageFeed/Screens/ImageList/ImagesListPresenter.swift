//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 02.06.2023.
//

import UIKit

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func getCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat
    func fetchPhotosNextPage()
    func updatePhotos()
    func changeLike(for photo: Photo, handler: @escaping (Result<Void, Error>) -> Void)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    var view: ImagesListViewControllerProtocol?
    
    private var imageListService: ImageListServiceProtocol
    private var imageListServiceObserver: NSObjectProtocol?
    private (set) var photos: [Photo] = []
    
    init(imageListService: ImageListServiceProtocol) {
        self.imageListService = imageListService
        
        self.imageListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main,
                         using: { [weak self] _ in
                
                guard let self = self else { return }
                
                let startIndex = self.photos.count
                self.updatePhotos()
                self.view?.updateTableViewAnimated(startIndex: startIndex, newCount: imageListService.photos.count)
            })
    }
    
    func getCellHeight(for photo: Photo, tableViewWidth: CGFloat) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableViewWidth - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        
        return cellHeight
    }
    
    func fetchPhotosNextPage() {
        imageListService.fetchPhotosNextPage()
    }
    
    func updatePhotos() {
        photos = imageListService.photos
    }
    
    func changeLike(for photo: Photo, handler: @escaping (Result<Void, Error>) -> Void) {
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoID: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                UIBlockingProgressHUD.dismiss()
                self.replacePhotoWithNewValue(photo: photo)
                handler(.success(()))
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                handler(.failure(error))
                
            }
        }
    }
    private func replacePhotoWithNewValue(photo: Photo) {
        if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
            let newPhoto = Photo(id: photo.id,
                                 size: photo.size,
                                 createdAt: photo.createdAt,
                                 welcomeDescription: photo.welcomeDescription,
                                 thumbImageURL: photo.thumbImageURL,
                                 largeImageURL: photo.largeImageURL,
                                 isLiked: !photo.isLiked)
            photos[index] = newPhoto
        }
    }
}
