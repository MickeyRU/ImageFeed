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
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private (set) var avatarURL: String?
    
    func fetchProfileImageURL(username: String, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        } else {
            let request = makeUserPhotoProfileRequest(username: username, token: token)
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profilePhoto):
                    guard let smallPhoto = profilePhoto.small else { return }
                    self.avatarURL = smallPhoto
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": smallPhoto]
                    )
                    completion(.success(smallPhoto))
                case .failure(let error):
                    self.task?.cancel()
                    completion(.failure(error))
                }
            }
            self.task = task
            task.resume()
        }
    }
    
    private func makeUserPhotoProfileRequest(username: String, token: String) -> URLRequest {
        var url = Constants.defaultBaseURL
        url.appendPathComponent("/users/\(username)")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // Создаем URLSessionTask и декодируем ответ в структуру ProfileResult
    private func object(for request: URLRequest, completion: @escaping (Result<ProfileImage, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileImage, Error> in Result {
                try decoder.decode(ProfileImage.self, from: data)
                }
            }
            completion(response)
            self.task = nil
        }
    }
}
