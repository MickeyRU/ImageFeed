//
//  ViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 16.03.2023.
//

import UIKit

public protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    var presenter: ImagesListPresenterProtocol?
    
    // MARK: - IBOutlet
    
    @IBOutlet private var tableView: UITableView!
    
    // MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imageListService = ImagesListService.shared
    private var photos: [Photo] = []
    private var imageListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "dd MMMM yyyy"
        return formatter
    }()
    
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
}

// MARK: Конфигурируем ячейку

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with IndexPath: IndexPath) {
        let imageUrl = photos[IndexPath.row].thumbImageURL
        let url = URL(string: imageUrl)
        let placeholder = Images.stubImage
        cell.photoImageView.kf.indicatorType = .activity
        cell.photoImageView.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [IndexPath], with: .automatic)
            cell.photoImageView.kf.indicatorType = .none
        }
        if let date = imageListService.photos[IndexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        let isLiked = imageListService.photos[IndexPath.row].isLiked == false
        let likeImage = isLiked ? Images.isNotLiked : Images.isLiked
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.selectionStyle = .none
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
        
        imageListCell.delegate = self
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}
// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        imageListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.photos = self.imageListService.photos
                cell.setIsLiked(isLiked: self.photos[indexPath.row].isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                self.showLikeErrorAlert(with: error)
            }
        }
    }
    
    private func showLikeErrorAlert(with: Error) {
        let alert = UIAlertController(
            title: "Что-то пошло не так(",
            message: "Не удалось поставить лайк",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        alert.dismiss(animated: true)
        present(alert, animated: true)
    }
}
