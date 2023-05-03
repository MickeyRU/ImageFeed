//
//  Constants.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 13.04.2023.
//

import UIKit

enum Constants {
    static let accessKey: String = "F7KZOMl0r5BGerBUC2H6WpsAbCTiIhPz-X_o55PCeGA"
    static let secretKey: String = "Qao4hjYq28RSvbc-1X3WewDLLCmO1q1GTPLOFsIHRvE"
    static let accessScope: String = "public+read_user+write_likes"
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}


