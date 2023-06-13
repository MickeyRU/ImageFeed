//
//  ViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 16.03.2023.
//

import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func updateTableViewAnimated(startIndex: Int, newCount: Int)
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
        
        if presenter?.photos.count == 0 {
            presenter?.fetchPhotosNextPage()
        }
    }
    
    // MARK: - Public methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let singleViewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            let singlePhoto = presenter?.photos[indexPath.row]
            singleViewController.modalPresentationCapturesStatusBarAppearance = true
            singleViewController.photo = singlePhoto
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    func updateTableViewAnimated(startIndex: Int, newCount: Int) {
        tableView.performBatchUpdates {
            var rows = [IndexPath]()
            for n in startIndex..<newCount {
                rows.append(IndexPath(row: n, section: 0))
            }
            tableView.insertRows(at: rows, with: .automatic)
        }
    }
}

// MARK: Конфигурируем ячейку

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with IndexPath: IndexPath) {
        guard
            let imageUrl = presenter?.photos[IndexPath.row].thumbImageURL,
            let url = URL(string: imageUrl)
        else { return }
        let placeholder = Images.stubImage
        cell.photoImageView.kf.indicatorType = .activity
        cell.photoImageView.kf.setImage(with: url, placeholder: placeholder) { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadRows(at: [IndexPath], with: .automatic)
            cell.photoImageView.kf.indicatorType = .none
        }
        if let date = presenter?.photos[IndexPath.row].createdAt {
            cell.dateLabel.text = dateFormatter.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        let isLiked = presenter?.photos[IndexPath.row].isLiked == false
        let likeImage = isLiked ? Images.isNotLiked : Images.isLiked
        cell.likeButton.setImage(likeImage, for: .normal)
        cell.selectionStyle = .none
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let presenter = presenter else { return tableView.rowHeight }
        
        let photo = presenter.photos[indexPath.row]
        return presenter.getCellHeight(for: photo, tableViewWidth: tableView.bounds.width)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let photosCount = presenter?.photos.count ?? 0
        
        if indexPath.row + 1 == photosCount {
            presenter?.fetchPhotosNextPage()
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
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
        guard
            let indexPath = tableView.indexPath(for: cell),
            let photo = presenter?.photos[indexPath.row]
        else { return }
        
        presenter?.changeLike(for: photo) { [weak self ]result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                cell.setIsLiked(isLiked: photo.isLiked)
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(let error):
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
