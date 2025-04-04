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
    var userParameters = UserParameters()
    var selectedTab: MenuTab = .api
    var isLoadMore = false
  }
  
  enum Action: Equatable {
    /// 검색어 입력
    case searchTextDidChange(String)
    /// 검색 API 호출
    case callSearchUsersAPI(UserParameters)
    /// profile 업데이트
    case updateProfile([Profile], Bool = false)
    /// 검색 API 호출 (LoadMore)
    case loadMore(Int)
    /// API 새로고침
    case refreshAPI
    /// 프로필 초기화
    case resetProfile
    /// 메뉴 탭 선택
    case selectedTabDidChange(MenuTab)
  }
  
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
            await send(.updateProfile(result.profile ?? []))
          } catch {
            print(error.localizedDescription)
            await send(.resetProfile)
          }
        }
        
      case let .updateProfile(profiles, isLoadMore):
        state.isLoadMore = isLoadMore
        if isLoadMore {
          state.profile.append(contentsOf: profiles)
          state.isLoadMore = false
        } else {
          state.profile = profiles
        }
        return .none
        
      case let .loadMore(index):
        if index == state.profile.count - 4 && !state.isLoadMore {
          state.userParameters.page += 1
          return .run { [param = state.userParameters] send in
            do {
              let result = try await apiManager.searchUsers(param: param)
//              print("loadMore: \(index)")
              await send(.updateProfile(result.profile ?? [], true))
            } catch {
              print(error.localizedDescription)
            }
          }
        }
        return .none
        
      case .refreshAPI:
        state.userParameters.page = 1
        return .run { [param = state.userParameters] send in
          await send(.callSearchUsersAPI(param))
        }
        
      case .resetProfile:
        state.profile = []
        return .none
        
      case let .selectedTabDidChange(tab):
        if state.selectedTab == tab {
          return .none
        }
        state.selectedTab = tab
        return .none
      }
    }
  }
}
