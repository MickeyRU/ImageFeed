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
    
    // MARK: - IBOutlet

    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Private Properties
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.kf.cancelDownloadTask()
    }
    
    func setIsLiked(isLiked: Bool) {
        let likeImage = isLiked ? Images.isLiked : Images.isNotLiked
           likeButton.setImage(likeImage, for: .normal)
       }
    
    
    // MARK: - IBAction

    @IBAction private func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
