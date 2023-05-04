//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 02.05.2023.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        } else {
            let request = makeUserProfileRequest(token: token)
            let task = object(for: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let profileData):
                    let convertedProfile = self.convertProfile(profile: profileData)
                    self.profile = convertedProfile
                    completion(.success(profileData))
                case .failure(let error):
                    self.task?.cancel()
                    completion(.failure(error))
                }
            }
            self.task = task
            task.resume()
        }
    }
    
    // Конвертируем приходящую модель профайла с сервера в модель для отображения в UI
    func convertProfile (profile: ProfileResult) -> Profile {
        let profile = Profile(
            username: profile.userLogin,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.userLogin)",
            bio: profile.bio)
        return profile
    }
    
    private func makeUserProfileRequest(token: String) -> URLRequest {
        var url = Constants.defaultBaseURL
        url.appendPathComponent("me")
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // Создаем URLSessionTask и декодируем ответ в структуру ProfileResult
    private func object(for request: URLRequest, completion: @escaping (Result<ProfileResult, Error>) -> Void) -> URLSessionTask {
        let decoder = JSONDecoder()
        return urlSession.data(for: request) { (result: Result<Data, Error>) in
            let response = result.flatMap { data -> Result<ProfileResult, Error> in Result {
                try decoder.decode(ProfileResult.self, from: data)
                }
            }
            completion(response)
            self.task = nil
        }
    }
}
