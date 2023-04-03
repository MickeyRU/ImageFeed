//
//  UIView+Extension.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 03.04.2023.
//

import UIKit

extension UIView {
    func addViews(_ view: UIView){
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
}
