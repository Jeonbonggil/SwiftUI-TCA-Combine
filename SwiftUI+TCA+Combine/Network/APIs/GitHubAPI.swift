//
//  GitHubAPI.swift
//  GithubUserFavorite
//
//  Created by Bonggil Jeon on 5/3/24.
//

import Foundation
import Moya

// MARK: - Provider support
public struct UserParameters: Equatable {
    var name: String
    var page: Int
    var perPage: Int
}

public enum GitHubAPI {
    case searchUsers(UserParameters)
}

extension GitHubAPI: TargetType {
    public var baseURL: URL {
        let domain = Bundle.main.object(forInfoDictionaryKey: "GitHubDomain") as? String ?? ""
        return URL(string: domain)!
    }
    public var path: String {
        switch self {
        case .searchUsers:
            return "/search/users"
        }
    }
    public var method: Moya.Method {
        switch self {
        case .searchUsers:
            return .get
        }
    }
    public var task: Task {
        switch self {
        case .searchUsers(let param):
            return .requestParameters(
                parameters: [
                    "q": param.name,
                    "order": "asc",
                    "page": param.page,
                    "per_page": param.perPage
                ],
                encoding: URLEncoding.default
            )
        }
    }
    public var validationType: ValidationType {
        switch self {
        case .searchUsers:
            return .successCodes
        }
    }
    public var headers: [String: String]? {
        let headers = [
            "Accept": "application/vnd.github+json",
            "X-GitHub-Api-Version": "2022-11-28"
        ]
        return headers
    }
    public var sampleData: Data {
        switch self {
        case .searchUsers(let param):
            return "{\"q\": \"\(param.name)\", \"order\": \"asc\", \"page\": \(param.page), \"per_page\": \(param.perPage)}"
                .data(using: .utf8)!
        }
    }
}
