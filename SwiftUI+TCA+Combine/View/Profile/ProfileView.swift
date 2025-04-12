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
  let store: StoreOf<ProfileFeature>
  private let imageSize = 60.0
  private let starSize = 30.0
  @State private var viewHeight = 125.0
  @State private var initialHeight = 0.0
  @State private var showingWebviewSheet = false
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      WithPerceptionTracking {
        VStack(alignment: .leading, spacing: 0) {
          Text(viewStore.profile.initial)
            .font(.system(size: 17.0, weight: .bold))
            .foregroundColor(.black)
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
            .frame(maxWidth: Screen.width, alignment: .leading)
            .background(
              GeometryReader { geometry in
                Color.clear
                  .onAppear {
                    if viewStore.profile.initial == "" {
                      initialHeight = geometry.size.height
                      viewHeight -= initialHeight
                    }
                    print("geometry: \(geometry.size.height), viewHeight: \(viewHeight)")
                  }
              }
            )
          
          HStack(alignment: .center, spacing: 0) {
            if let imageUrl = viewStore.profile.profileURL {
              KFImage(URL(string: imageUrl))
                .resizable()
                .scaledToFill()
                .clipShape(Circle())
                .overlay(Circle().stroke(.black, lineWidth: 1))
                .frame(width: imageSize, height: imageSize)
            } else {
              Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: imageSize, height: imageSize)
                .foregroundStyle(.gray)
                .clipShape(Circle())
                .overlay(Circle().stroke(.black, lineWidth: 1))
            }
            
            Text(viewStore.profile.userName ?? "")
              .font(.system(size: 17.0))
              .foregroundColor(.black)
              .lineLimit(2)
              .padding(EdgeInsets(top: 0, leading: 19, bottom: 0, trailing: 15))
              .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
              .contentShape(Rectangle())
            
            Image(systemName: viewStore.profile.isFavorite ? "star.fill" : "star")
              .foregroundStyle(.blue)
              .frame(width: starSize, height: starSize)
              .contentShape(Rectangle())
              .onTapGesture {
                viewStore.send(.favoriteButtonTapped)
              }
          }
          .padding(.horizontal, 15)
          .frame(width: Screen.width, alignment: .leading)
          .frame(maxHeight: .infinity, alignment: .leading)
          .onTapGesture {
            showingWebviewSheet.toggle()
          }
          .sheet(isPresented: $showingWebviewSheet) {
            RepoWebView(url: viewStore.profile.repositoryURL)
              .presentationDragIndicator(.visible)
          }
        }
        .frame(width: Screen.width, height: viewHeight)
        .onChange(of: viewStore.profile.initial) { newValue in
          if newValue.isEmpty {
            viewHeight -= initialHeight
          } else {
            viewHeight = 105.0
          }
          print("viewHeight: \(viewHeight), newValue: \(newValue)")
        }
      }
    }
  }
}

#Preview {
  ProfileView(
    store: Store(
      initialState: ProfileFeature.State(profile: Profile.preview),
      reducer: {
        ProfileFeature()
      }
    )
  )
}
