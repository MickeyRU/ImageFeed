//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Павел Афанасьев on 05.06.2023.
//

import Foundation
@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var didInsertedRowsAfterFetching: Bool = false
    var presenter: ImagesListPresenterProtocol?
    
    func updateTableViewAnimated(startIndex: Int, newCount: Int) {
        didInsertedRowsAfterFetching = true
    }
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
}

