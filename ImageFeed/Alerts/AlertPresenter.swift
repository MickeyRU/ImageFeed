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
    
    func createAlert(alertTitle: String, alertMessage: String, handler: @escaping () -> Void) {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            handler()
        }
        alert.addAction(alertAction)
        delegate?.showAlert(alert: alert)
    }
    
    func prepeareAlertForExit (alertTitle: String, alertMessage: String, alertActions: [UIAlertAction]) {
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        
        alertActions.forEach { action in
            alert.addAction(action)
        }
        delegate?.showAlert(alert: alert)
    }
}
