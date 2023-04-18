//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 18.04.2023.
//

import Foundation

final class OAuth2TokenStorage {
    var token: String {
        get {
            guard let token = userDefaults.string(forKey: Keys.token.rawValue) else {
                print("Нет сохраненного токена в UserDefaults")
                return ""
            }
            return token
        }
        set {
            userDefaults.set(newValue, forKey: Keys.token.rawValue)
        }
    }
    
    private enum Keys: String {
        case token
    }
    
    private let userDefaults = UserDefaults.standard
}
