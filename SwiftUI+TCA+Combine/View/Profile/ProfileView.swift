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
  private let starSzie = 30.0
  @State private var viewHeight = 105.0
  @State private var initialHeight = 0.0
  @State private var showingWebviewSheet = false
  
  var body: some View {
    WithViewStore(store, observe: { $0.profile }) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text(viewStore.initial)
          .font(.system(size: 17.0, weight: .bold))
          .foregroundColor(.black)
          .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
          .frame(maxWidth: Screen.width, maxHeight: .infinity, alignment: .leading)
          .background(
            GeometryReader { proxy in
              // TODO: - UI 높이 처리 시 깨짐 현상 수정 필요
              WithPerceptionTracking {
                Color.clear
                  .onAppear {
//                    let calculatedHeight = viewStore.initial.isEmpty ? proxy.size.height : 0
//                    print("proxy.size.height: \(proxy.size.height), calculatedHeight: \(calculatedHeight), initialHeight: \(initialHeight), viewHeight: \(viewHeight)")
//                    if calculatedHeight.isFinite && calculatedHeight >= 0 {
//                      initialHeight = calculatedHeight
//                      viewHeight = max(0, viewHeight - initialHeight)
//                    }
                  }
              }
            }
          )
          .onChange(of: viewStore.initial) { newValue in
            if newValue.isEmpty {
              viewHeight = viewHeight - 20.0
            } else {
              viewHeight = 105
            }
          }
        
        HStack(alignment: .center, spacing: 0) {
          if let imageUrl = viewStore.profileURL {
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
          
          Text(viewStore.userName ?? "")
            .font(.system(size: 17.0))
            .foregroundColor(.black)
            .lineLimit(2)
            .padding(EdgeInsets(top: 0, leading: 19, bottom: 0, trailing: 15))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .contentShape(Rectangle())
          
          Image(systemName: viewStore.isFavorite ? "star.fill" : "star")
            .foregroundStyle(.blue)
            .frame(width: starSzie, height: starSzie)
            .contentShape(Rectangle())
            .onTapGesture {
              viewStore.send(.favoriteButtonTapped)
            }
        }
        .padding(.horizontal, 15)
        .frame(width: Screen.width, alignment: .leading)
        .onTapGesture {
          showingWebviewSheet.toggle()
        }
        .sheet(isPresented: $showingWebviewSheet) {
          RepoWebView(url: viewStore.repositoryURL)
            .presentationDragIndicator(.visible)
        }
        
      }
      .frame(width: Screen.width, height: viewHeight)
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
