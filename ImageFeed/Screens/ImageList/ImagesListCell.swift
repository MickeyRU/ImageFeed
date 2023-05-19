//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 17.03.2023.
//

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    
    var reloadRowClosure: (() -> Void)?
    
    // MARK: - IBOutlet

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Private Properties
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
    }
    
    public func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? Images.isNotLiked : Images.isLiked
           likeButton.setImage(likeImage, for: .normal)
       }
    
    func configureCell(photo: Photo) {
        if let imageUrl = URL(string: photo.thumbImageURL) {
            let processor = RoundCornerImageProcessor(cornerRadius: 16)
            photoImageView.kf.indicatorType = .activity
            photoImageView.kf.setImage(
                with: imageUrl,
                placeholder: Images.stubImage,
                options: [.processor(processor)]) { [weak self] _ in
                    guard let self = self else { return }
                    self.reloadRowClosure?()
                }
        } else {
            photoImageView.image = Images.stubImage
        }
        dateLabel.text = photo.createdAt != nil ? dateFormatter.string(from: photo.createdAt!) : ""
    }
    
    // MARK: - IBAction

    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
