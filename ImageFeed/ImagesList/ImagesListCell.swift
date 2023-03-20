//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 17.03.2023.
//

import UIKit

final class ImagesListCell: UITableViewCell {
    // MARK: - Public Properties
    static let reuseIdentifier = "ImagesListCell"
    
    // MARK: - IBOutlet
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
}
