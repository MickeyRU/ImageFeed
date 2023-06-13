//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Павел Афанасьев on 26.05.2023.
//

import Foundation
import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var loadRequestCalled: Bool = false
    var presenter: WebViewPresenterProtocol?
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
