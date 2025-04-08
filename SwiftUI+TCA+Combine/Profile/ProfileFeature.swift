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
  struct State: Equatable {
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
    /// 즐겨찾기 초성 만들기
    case configureInitial
  }
  
  @Dependency(\.mainQueue) var mainQueue
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      let persistenceManager = PersistenceManager()
      let fetchRequest = persistenceManager.myFetchRequest
      switch action {
      case .favoriteButtonTapped:
        let profile = state.profile
        Task {
          let managedObejct = await persistenceManager.fetch(request: fetchRequest)
          if let userName = profile.userName,
             let index = managedObejct.firstIndex(where: { $0.userName == userName }) {
            return
          }
        }
        state.profile.isFavorite.toggle()
        return .run { [isFavorite = state.profile.isFavorite] send in
          isFavorite ? await send(.saveFavorite) : await send(.deleteFavorite)
        }
        
      case .saveFavorite:
        let favoriteProfile = state.profile
        Task { await persistenceManager.saveFavorite(favorite: favoriteProfile) }
        return .none
        
      case .deleteFavorite:
        let favoriteProfile = state.profile
        Task {
          let managedObejct = await persistenceManager.fetch(request: fetchRequest)
          if let userName = favoriteProfile.userName,
             let index = managedObejct.firstIndex(where: { $0.userName == userName }) {
            await persistenceManager.deleteFavorite(object: managedObejct[index])
          }
        }
        return .none
        
      case .configureInitial:
        var searchList = state.favoriteList
        if state.favoriteList.count > 0 {
          searchList = state.searchFavoriteList
        }
        let initList = searchList.dropFirst()
        let initial = initList.first?.initial?.uppercased() ?? ""
        
        return .none
        
      }
    }
  }
}
