//
//  ProfileView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/24/25.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct ProfileView: View {
  private struct DrawingConstants {
    static let initialEdgeInsets = EdgeInsets(top: 10, leading: 15, bottom: 0, trailing: 15)
    static let usernameEdgeInsets = EdgeInsets(top: 0, leading: 19, bottom: 0, trailing: 15)
    static let imageSize = 60.0
    static let starSize = 30.0
    static let contentHeight = 85.0
  }
  
  let store: StoreOf<ProfileFeature>
  @State private var showingWebviewSheet = false
  
  var body: some View {
    WithPerceptionTracking {
      VStack(alignment: .leading, spacing: 0) {
        let initial = store.profile.initial
        if !initial.isEmpty {
          Text(initial)
            .font(.system(size: 17.0, weight: .bold))
            .foregroundColor(.black)
            .padding(DrawingConstants.initialEdgeInsets)
            .frame(maxWidth: Screen.width, alignment: .leading)
        }
        
        HStack(alignment: .center, spacing: 0) {
          if let imageUrl = store.profile.profileURL {
            KFImage(URL(string: imageUrl))
              .resizable()
              .scaledToFill()
              .clipShape(Circle())
              .overlay(Circle().stroke(.black, lineWidth: 1))
              .frame(width: DrawingConstants.imageSize, height: DrawingConstants.imageSize)
          } else {
            Image(systemName: "person.circle.fill")
              .resizable()
              .frame(width: DrawingConstants.imageSize, height: DrawingConstants.imageSize)
              .foregroundStyle(.gray)
              .clipShape(Circle())
              .overlay(Circle().stroke(.black, lineWidth: 1))
          }
          
          Text(store.profile.userName ?? "")
            .font(.system(size: 17.0))
            .foregroundColor(.black)
            .lineLimit(2)
            .padding(DrawingConstants.usernameEdgeInsets)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
          
          Image(systemName: store.profile.isFavorite ? "star.fill" : "star")
            .foregroundStyle(.blue)
            .frame(width: DrawingConstants.starSize, height: DrawingConstants.starSize)
            .contentShape(Rectangle())
            .onTapGesture {
              store.send(.favoriteButtonTapped)
            }
        }
        .padding(.horizontal, 15)
        .frame(width: Screen.width, height: DrawingConstants.contentHeight, alignment: .leading)
        .frame(maxHeight: .infinity, alignment: .leading)
        .onTapGesture {
          showingWebviewSheet.toggle()
        }
        .sheet(isPresented: $showingWebviewSheet) {
          RepoWebView(url: store.profile.repositoryURL)
            .presentationDragIndicator(.visible)
        }
      }
      .frame(width: Screen.width)
    }
  }
}

#Preview {
  ProfileView(
    store: Store(
      initialState: ProfileFeature.State(profile: Profile.preview),
      reducer: { ProfileFeature() }
    )
  )
}
