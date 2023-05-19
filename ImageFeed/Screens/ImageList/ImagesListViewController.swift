//
//  ViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 16.03.2023.
//

import UIKit

final class ImagesListViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imageListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    private let alertPresenter = AlertPresenter()
    
    
    // MARK: - VC LC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        
        if photos.count == 0 {
            imageListService.fetchPhotosNextPage()
        }
        imageListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            })
        
        alertPresenter.delegate = self
    }
    
    // MARK: - Public methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let singleViewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let singlePhoto = photos[indexPath.row]
            singleViewController.modalPresentationCapturesStatusBarAppearance = true
            singleViewController.photo = singlePhoto
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private methods
    
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imageListService.photos.count
        photos = imageListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    private func reloadRowForTable(indexPath: IndexPath) {
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func replacePhotoWithNewLikeValue(photo: Photo) {
        if let index = self.photos.firstIndex(where: { $0.id == photo.id }) {
            let newPhoto = Photo(
                id: photo.id,
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

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photo.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == photos.count {
            imageListService.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = photos[indexPath.row]
        imageListCell.delegate = self
        imageListCell.reloadRowClosure = { [weak self] in
            guard let self = self else { return }
            self.reloadRowForTable(indexPath: indexPath)
        }
        imageListCell.configureCell(photo: photo)
        
        return imageListCell
    }
}

// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.replacePhotoWithNewLikeValue(photo: photo)
                    cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                    self.reloadRowForTable(indexPath: indexPath)
                    self.photos = self.imageListService.photos
                    UIBlockingProgressHUD.dismiss()
                case .failure(let error):
                    UIBlockingProgressHUD.dismiss()
                    self.alertPresenter.createAlert(
                        alertTitle: "Что-то пошло не так :(",
                        alertMessage: "Не удалось обработать нажатие на кнопку лайк, \(error.localizedDescription)") {
                        }
                }
            }
        }
    }
}

extension ImagesListViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}
