//
//  ImagesListTests.swift
//  ImagesFeedTests
//
//  Created by Павел Афанасьев on 02.06.2023.
//

@testable import ImageFeed
import XCTest

final class ImagesListTests: XCTestCase {
    func testGetNewPhotosFromPresenter() {
        //given
        let imageServiceMock = ImageListServiceStub()
        let presenter = ImagesListPresenter(imageListService: imageServiceMock)
        
        //when
        presenter.fetchPhotosNextPage()
        presenter.updatePhotos()
        
        //then
        XCTAssertTrue(presenter.photos.count == 3)
    }
    
    func testDidInsertedRowsAfterFetching() {
        //given
        let imageServiceMock = ImageListServiceStub()
        let presenter = ImagesListPresenter(imageListService: imageServiceMock)
        let imageListVCSpy = ImagesListViewControllerSpy()
        imageListVCSpy.configure(presenter)
        
        //when
        presenter.fetchPhotosNextPage()
        
        //then
        XCTAssertTrue(imageListVCSpy.didInsertedRowsAfterFetching)
        
    }
}
