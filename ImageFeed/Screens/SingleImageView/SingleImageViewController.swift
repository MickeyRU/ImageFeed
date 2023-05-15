//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 31.03.2023.
//

import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    var photo: Photo! {
        didSet {
            guard isViewLoaded else { return }
            setImage()
        }
    }
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var shareButton: UIButton!
    
    // MARK: - Private Properties
    
    private let alertPresenter = AlertPresenter()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter.delegate = self
        
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
    }
    
    // MARK: - IBAction
    
    @IBAction private func didTapBackButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        if let image = imageView.image {
            let imageShape = [image]
            let activityViewController = UIActivityViewController(
                activityItems: imageShape,
                applicationActivities: nil
            )
            present(activityViewController, animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func setImage() {
        UIBlockingProgressHUD.show()
        if let imageUrl = URL(string: photo.largeImageURL) {
            imageView.kf.setImage(
                with: imageUrl,
                placeholder: Images.stubImage) { [weak self] result in
                    UIBlockingProgressHUD.dismiss()
                    guard let self = self else { return }
                    switch result {
                    case .success(let imageResult):
                        self.rescaleAndCenterImageInScrollView(image: imageResult.image)
                    case .failure(let error):
                        self.alertPresenter.createAlert(
                            title: "Что-то пошло не так :(",
                            message: "Не удалось загрузить фото \(error.localizedDescription)") {
                                self.imageView.image = Images.stubImage
                            }
                    }
                }
        } else {
            imageView.image = Images.stubImage
        }
    }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func centerImage() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: 0, right: 0)
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerImage()
    }
}

extension SingleImageViewController: AlertPresenterDelegate {
    func showAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
    
    
}
