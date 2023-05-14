//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 03.05.2023.
//

import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    private var currentTask: URLSessionTask?
    private let networkClient = NetworkClient.shared
    
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(userName: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if currentTask != nil {
            currentTask?.cancel()
        } else {
            guard let urlRequestProfileData = makeUserPhotoProfileRequest(userName: userName) else { return }
            let task = networkClient.getObject(dataType: ProfileResult.self, for: urlRequestProfileData) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profilePhoto):
                    guard let mediumPhoto = profilePhoto.profileImage?.medium else { return }
                    self.avatarURL = mediumPhoto
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": mediumPhoto]
                    )
                    completion(.success(mediumPhoto))
                case .failure(let error):
                    completion(.failure(error))
                }
                self.currentTask = nil
            }
            self.currentTask = task
            task.resume()
        }
    }
    
    private func makeUserPhotoProfileRequest(userName: String) -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/users/\(userName)", httpMethod: "GET", uRLString: Constants.defaultApiBaseURLString)
    }
}
