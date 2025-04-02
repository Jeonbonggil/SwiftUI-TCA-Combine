//
//  GitHubMainFeature.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/2/25.
//

import Foundation
import ComposableArchitecture

enum MenuTab: Int, Equatable, Identifiable, CaseIterable {
    case api
    case favorite
    
    var title: String {
        switch self {
        case .api: return "API"
        case .favorite: return "Favorite"
        }
    }
    
    var id: Int { return rawValue }
}

@Reducer
struct GitHubMainFeature {
    struct State: Equatable {
        var profile: [Profile] = []
        var searchText = ""
        var userParameters = UserParameters(name: "", page: 1, perPage: 30)
        var selectedTab: MenuTab = .api
    }
    
    enum Action: Equatable {
        // 검색어 입력
        case searchTextDidChange(String)
        // 검색 API 호출
        case callSearchUsersAPI(UserParameters)
        // profile 업데이트
        case updateProfile([Profile])
        case selectedTabDidChange(MenuTab)
    }
    
//    struct Environment {
//        var mainQueue: AnySchedulerOf<DispatchQueue>
//        var gitHubAPI: GitHubAPI
//    }
    
    @Dependency(\.mainQueue) var mainQueue
    @Dependency(\.gitHubAPIManager) var apiManager
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .searchTextDidChange(text):
                state.searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                state.userParameters.page = 1
                state.userParameters.name = state.searchText
                return .run { [param = state.userParameters] send in
                    await send(.callSearchUsersAPI(param))
                }
                
            case let .callSearchUsersAPI(userParameters):
                return .run { send in
                    do {
                        let result = try await apiManager.searchUsers(param: userParameters)
                        await send(.updateProfile(result.profile))
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                
            case let .updateProfile(profiles):
                state.profile = profiles
                return .none

            case let .selectedTabDidChange(tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}
