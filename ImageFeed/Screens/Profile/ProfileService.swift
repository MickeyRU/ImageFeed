//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Павел Афанасьев on 02.05.2023.
//

import UIKit

final class ProfileService {
    static let shared = ProfileService()
    
    private var currentTask: URLSessionTask?
    private let networkClient = NetworkClient.shared
    
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        currentTask?.cancel()
        guard let urlRequestSelfProfile = selfProfileRequest() else { return }
        let task = networkClient.getObject(dataType: ProfileResult.self, for: urlRequestSelfProfile) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let profileResult):
                let convertedProfile = self.convertProfile(profile: profileResult)
                self.profile = convertedProfile
                completion(.success(profileResult))
            case .failure(let error):
                completion(.failure(error))
            }
            self.currentTask = nil
        }
        self.currentTask = task
        task.resume()
    }
    
    func convertProfile (profile: ProfileResult) -> Profile {
        let profile = Profile(
            username: profile.userLogin,
            name: "\(profile.firstName ?? "") \(profile.lastName ?? "")",
            loginName: "@\(profile.userLogin)",
            bio: profile.bio)
        return profile
    }
    
    private func selfProfileRequest() -> URLRequest? {
        URLRequest.makeHTTPRequest(path: "/me", httpMethod: "GET", uRLString: Constants.defaultApiBaseURLString)
    }
}
