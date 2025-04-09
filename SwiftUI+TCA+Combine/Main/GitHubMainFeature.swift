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
  var xOffset: CGFloat {
    switch self {
    case .api: return 0
    case .favorite: return Screen.width / 2
    }
  }
  var menuWidth: CGFloat {
    switch self {
    case .api: return Screen.width / 2
    case .favorite: return Screen.width / 2
    }
  }
  var menuHeight: CGFloat {
    switch self {
    case .api: return 50
    case .favorite: return 50
    }
  }
  var id: Int { return rawValue }
}

@Reducer
struct GitHubMainFeature {
  @ObservableState
  struct State: Equatable {
    var profile: [Profile] = []
    var searchText = ""
    var userParameters = UserParameters()
    var selectedTab: MenuTab = .api
    var isLoadMore = false
  }
  
  enum Action: Equatable {
    /// 메뉴 탭 선택
    case selectedTabDidChange(MenuTab)
    /// 검색어 clear
    case clearSearchText
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
    /// 즐겨찾기 조회
    case favoriteListDidChange
  }
  
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.gitHubAPIManager) var apiManager
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .clearSearchText:
        state.searchText = ""
        return .none
        
      case let .selectedTabDidChange(tab):
        state.selectedTab = tab
        switch tab {
        case .api:
          state.userParameters.page = 1
          return .run { [text = state.searchText] send in
            await send(.searchTextDidChange(text))
          }
        case .favorite:
          state.profile = state.profile.isNotEmpty ? state.profile : []
          state.searchText = ""
          return .run { send in
            await send(.favoriteListDidChange)
          }
        }
        
      case let .searchTextDidChange(text):
        state.searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        state.userParameters.page = 1
        state.userParameters.name = state.searchText
        if state.searchText.isEmpty {
          state.profile = []
          return .none
        }
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
          print("loadMore: \(index)")
          return .run { [param = state.userParameters] send in
            do {
              let result = try await apiManager.searchUsers(param: param)
              guard let profile = result.profile, profile.isNotEmpty else { return }
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
        
      case .favoriteListDidChange:
        return .run { send in
          let persistenceManager = PersistenceManager()
          let fetchRequest = persistenceManager.myFetchRequest
          let favoriteList = await persistenceManager.fetch(request: fetchRequest)
          let updatedProfile = favoriteList.map {
            Profile(
              initial: $0.initial ?? "",
              userName: $0.userName ?? "",
              profileURL: $0.profileURL ?? "",
              repositoryURL: $0.repositoryURL ?? "",
              isFavorite: $0.isFavorite
            )
          }
          await send(.updateProfile(updatedProfile))
        }
      }
    }
  }
}
