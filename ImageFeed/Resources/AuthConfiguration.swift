//
//  AuthConfiguration.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 13.04.2023.
//

import UIKit

struct APIConstants {
    static let accessKey = "F7KZOMl0r5BGerBUC2H6WpsAbCTiIhPz-X_o55PCeGA"
    static let secretKey = "Qao4hjYq28RSvbc-1X3WewDLLCmO1q1GTPLOFsIHRvE"
    static let accessScope = "public+read_user+write_likes"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"

    static let defaultApiBaseURLString = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    
    static let baseURLString = "https://unsplash.com"
    static let baseAuthTokenPath = "/oauth/token"
    
    static let bearerToken = "bearerToken"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: APIConstants.accessKey,
            secretKey: APIConstants.secretKey,
            redirectURI: APIConstants.redirectURI,
            accessScope: APIConstants.accessScope,
            defaultBaseURL: URL(string: "APIConstants.defaultApiBaseURLString")!,
            authURLString: APIConstants.unsplashAuthorizeURLString)
    }
}



