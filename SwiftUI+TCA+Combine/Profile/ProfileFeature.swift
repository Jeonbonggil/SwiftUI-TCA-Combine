//
//  ProfileFeature.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/1/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileFeature {
  @ObservableState
  struct State: Equatable {
    var tab: MenuTab = .favorite
    var profiles: [Profile] = []
    var profile: Profile = .empty
    var favoriteProfile: Profile? = .empty
    /// 즐겨찾기 리스트
    var favoriteList = [GitHubFavorite]()
    /// 즐겨찾기 검색 리스트
    var searchFavoriteList = [GitHubFavorite]()
  }
  
  enum Action: Equatable {
    /// 즐겨찾기 버튼 클릭
    case favoriteButtonTapped
    /// 즐겨찾기 저장
    case saveFavorite
    /// 즐겨찾기 삭제
    case deleteFavorite
    /// 즐겨찾기 조회
    case fetchFavoriteList
    /// 업데이트 즐겨찾기 리스트
    case updateFavoriteList([GitHubFavorite])
    /// 즐겨찾기 초성 만들기
    case configureInitial
    /// Profile 업데이트
    case updateProfile([Profile])
  }
  
  @Dependency(\.mainQueue) var mainQueue
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      let persistenceManager = PersistenceManager()
      let fetchRequest = persistenceManager.fetchRequest
      switch action {
      case .favoriteButtonTapped:
        state.profile.isFavorite.toggle()
        return .run { [profile = state.profile] send in
          let managedObejct = await persistenceManager.fetch(request: fetchRequest)
          if let userName = profile.userName,
             let _ = managedObejct.firstIndex(where: { $0.userName == userName }) {
            await send(.deleteFavorite)
          } else {
            await send(.saveFavorite)
          }
        }
        
      case .saveFavorite:
        let favoriteProfile = state.profile
        return .run { send in
          await persistenceManager.saveFavorite(favorite: favoriteProfile)
          await send(.fetchFavoriteList)
        }
        
      case .deleteFavorite:
        let favoriteProfile = state.profile
        return .run { send in
          let managedObejct = await persistenceManager.fetch(request: fetchRequest)
          if let userName = favoriteProfile.userName,
             let index = managedObejct.firstIndex(where: { $0.userName == userName }) {
            await persistenceManager.deleteFavorite(object: managedObejct[index])
          }
          await send(.fetchFavoriteList)
        }
        
      case .fetchFavoriteList:
        return .run { send in
          let favoriteList = await persistenceManager.results().sorted {
            $0.userName?.localizedCaseInsensitiveCompare($1.userName ?? "") == .orderedAscending
          }
          favoriteList.forEach { favorite in
            let initial = favorite.userName?.prefix(1).uppercased()
            if let index = favoriteList.firstIndex(where: {
              $0.userName?.first?.uppercased() == initial
            }) {
              favoriteList[index].initial = initial
            }
          }
          await send(.updateFavoriteList(favoriteList))
        }
        
      case .updateFavoriteList(let favoriteList):
        state.favoriteList = favoriteList
        print("favoriteList: \(favoriteList)")
        return .run { send in
          await send(.configureInitial)
        }
        
      case .configureInitial:
        return .run { [favoriteList = state.favoriteList] send in
          let profiles = favoriteList.map {
            Profile(
              initial: $0.initial ?? "",
              userName: $0.userName ?? "",
              profileURL: $0.profileURL ?? "",
              repositoryURL: $0.repositoryURL ?? "",
              isFavorite: $0.isFavorite
            )
          }
          await send(.updateProfile(profiles))
        }
        
      case let .updateProfile(profiles):
        state.profiles = profiles
        return .none
        
      }
    }
  }
}
