//
//  ImagesListPresenterProtocol.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 02.06.2023.
//

import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    
    
}
