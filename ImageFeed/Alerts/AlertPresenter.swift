//
//  AlertPresenter.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 12.05.2023.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(alert: UIAlertController)
}

final class AlertPresenter {    
    weak var delegate: AlertPresenterDelegate?
    
    func createAlert(title: String, message: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            handler()
        }
        alert.addAction(alertAction)
        delegate?.showAlert(alert: alert)
    }
}
