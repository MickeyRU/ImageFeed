//
//  Constants.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 13.04.2023.
//

import UIKit

enum Constants {
    
    // MARK: Unsplash api base paths
    static let defaultApiBaseURLString = "https://api.unsplash.com"
    static let baseURLString = "https://unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let baseAuthTokenPath = "/oauth/token"

    
    // MARK: Unsplash api constants
    static let accessKey = "F7KZOMl0r5BGerBUC2H6WpsAbCTiIhPz-X_o55PCeGA"
    static let secretKey = "Qao4hjYq28RSvbc-1X3WewDLLCmO1q1GTPLOFsIHRvE"
    static let accessScope = "public+read_user+write_likes"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    
}


