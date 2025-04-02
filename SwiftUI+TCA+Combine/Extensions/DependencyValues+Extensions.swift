//
//  DependencyValues+Extensions.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/2/25.
//

import ComposableArchitecture

extension DependencyValues {
    var gitHubAPIManager: GitHubAPIManager {
        get { self[GitHubAPIManagerKey.self] }
        set { self[GitHubAPIManagerKey.self] = newValue }
    }
    
    private enum GitHubAPIManagerKey: DependencyKey {
        static let liveValue = GitHubAPIManager.shared
    }
}

