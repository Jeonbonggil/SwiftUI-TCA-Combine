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
    /// 자식 State
    var profileFeatures: IdentifiedArrayOf<ProfileFeature.State> = []
    var profiles: [Profile] = []
    var searchText = ""
    var userParameters = UserParameters()
    var selectedTab: MenuTab = .api
    var isLoadMore = false
  }
  
  enum Action: Equatable {
    /// 자식 액션
    case profileFeatures(IdentifiedActionOf<ProfileFeature>)
    /// 메뉴 탭 선택
    case selectedTabDidChange(MenuTab)
    /// 검색어 clear
    case clearSearchText
    /// 검색어 입력
    case searchTextDidChange(String)
    /// 검색 API 호출
    case fetchSearchUsers(UserParameters, Bool = false)
    /// profile 업데이트
    case updateProfile([Profile], Bool = false)
    /// 아이템이 나타났을 때 호출
    case itemAppeared(id: UUID)
    /// 검색 API 호출 (LoadMore)
    case loadMore(Int)
    /// API 새로고침
    case refreshAPI
    /// 프로필 초기화
    case resetProfile
    /// 즐겨찾기 조회
    case favoriteListDidChange
    /// 즐겨찾기 리스트 업데이트
    case updateFavoriteList([GitHubFavorite])
    /// 부모에게 즐겨찾기 변경 알림
    case notifyFavoriteChanged
  }
  
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.gitHubAPIManager) var apiManager
  
  enum CancelID { case searchDebounce }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case let .selectedTabDidChange(tab):
        state.selectedTab = tab
        switch tab {
        case .api:
          return .run { [text = state.searchText] send in
            await send(.searchTextDidChange(text))
          }
        case .favorite:
          return .run { send in
            await send(.favoriteListDidChange)
          }
        }
        
      case .clearSearchText:
        state.searchText = ""
        return .none
        
      case let .searchTextDidChange(text):
        state.searchText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        state.userParameters = UserParameters(name: state.searchText, page: 1)
        if state.searchText.isEmpty {
          state.profiles = []
          return .none
        }
        return .run { [param = state.userParameters] send in
          await send(.fetchSearchUsers(param))
        }
        
      case let .fetchSearchUsers(param, isLoadMore):
        state.userParameters.page = isLoadMore ? param.page : 1
        return .run { send in
          do {
            let result = try await apiManager.searchUsers(param: param)
            await send(.updateProfile(result.profile ?? [], isLoadMore))
          } catch {
            print(error.localizedDescription)
            await send(.resetProfile)
          }
        }
        
      case let .updateProfile(profiles, isLoadMore):
        state.isLoadMore = isLoadMore
        if isLoadMore {
          state.profiles.append(contentsOf: profiles)
          state.isLoadMore = false
        } else {
          state.profiles = profiles
        }
        state.profileFeatures = IdentifiedArrayOf(uniqueElements: state.profiles.map {
          ProfileFeature.State(tab: state.selectedTab, profile: $0)
        })
        return .none
        
      case let .itemAppeared(id):
        // id를 사용해 배열의 인덱스를 찾습니다.
        guard let index = state.profileFeatures.firstIndex(where: { $0.id == id }) else {
          return .none
        }
        // 찾은 인덱스로 기존 loadMore 액션을 호출합니다.
        return .send(.loadMore(index))
        
      case let .loadMore(index):
        guard state.selectedTab == .api,
              state.profiles.count > 4,
              index == state.profiles.count - 4,
              !state.isLoadMore else { return .none }
        state.userParameters.page += 1
        print("loadMore: \(index)")
        return .run { [param = state.userParameters] send in
          await send(.fetchSearchUsers(param, true))
        }
        
      case .refreshAPI:
        state.userParameters.page = 1
        return .run { [param = state.userParameters] send in
          await send(.fetchSearchUsers(param))
        }
        
      case .resetProfile:
        state.profiles = []
        return .none
        
      case .favoriteListDidChange:
        return .run { send in
          var favoriteList = await PersistenceManager.shared.results()
          for object in favoriteList {
            let initial = object.userName?.prefix(1).uppercased()
            if let index = favoriteList.firstIndex(where: {
              $0.userName?.first?.uppercased() == initial
            }) {
              favoriteList[index].initial = initial
            }
            print("favoriteList: \(object.initial ?? ""), \(object.userName ?? ""), \(object.isFavorite)")
          }
          favoriteList = favoriteList.sorted {
            $0.initial?.localizedCaseInsensitiveCompare($1.initial ?? "") == .orderedAscending
          }
          await send(.updateFavoriteList(favoriteList))
        }

      case let .updateFavoriteList(favoriteList):
        if favoriteList.isEmpty {
          return .none
        } else {
          state.profiles = favoriteList.map {
            Profile(
              initial: $0.initial ?? "",
              userName: $0.userName ?? "",
              profileURL: $0.profileURL ?? "",
              repositoryURL: $0.repositoryURL ?? "",
              isFavorite: $0.isFavorite
            )
          }
          state.profileFeatures = IdentifiedArrayOf(uniqueElements: state.profiles.map {
            ProfileFeature.State(tab: state.selectedTab, profile: $0)
          })
          return .none
        }
        
      case .profileFeatures(.element(id: _, action: .notifyFavoriteChanged)):
        return .run { send in
          await send(.favoriteListDidChange)
        }

      default:
        return .none
        
      }
    }
    .forEach(\.profileFeatures, action: \.profileFeatures) {
      ProfileFeature()
    }
  }
}
