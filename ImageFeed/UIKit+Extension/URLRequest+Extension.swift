//
//  URLRequest+Extension.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 02.05.2023.
//

import Foundation

extension URLRequest {
    static func makeHTTPRequest(path: String, httpMethod: String, uRLString: String) -> URLRequest? {
        guard
            let url = URL(string: uRLString),
            let baseUrl = URL(string: path, relativeTo: url)
        else { return nil }
        
        var request = URLRequest(url: baseUrl)
        request.httpMethod = httpMethod
        
        if uRLString == APIConstants.defaultApiBaseURLString {
            guard let authToken = OAuth2TokenStorage.shared.token else { return nil }
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
