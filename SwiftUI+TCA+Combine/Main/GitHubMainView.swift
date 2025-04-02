//
//  ContentView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/19/25.
//

import SwiftUI
import ComposableArchitecture

struct GitHubMainView: View {
  let store: StoreOf<GitHubMainFeature>
  private let buttonWidth = Screen.width / 2
  private let buttonHeight = 50.0
  @State private var barPoint = CGPoint(x: 0, y: 0)
  @State private var searchText = ""
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text("Github Stars")
          .font(.title)
          .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 0))
        
        VStack(spacing: 0) {
          ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
              Button {
                withAnimation {
                  barPoint.x = 0
                }
              } label: {
                Text(MenuTab.api.title)
                  .frame(width: buttonWidth, height: buttonHeight)
                  .border(Color.black, width: 1)
                  .foregroundStyle(Color.black)
              }
              
              Button {
                withAnimation {
                  barPoint.x = buttonWidth
                }
              } label: {
                Text(MenuTab.favorite.title)
                  .frame(width: buttonWidth, height: buttonHeight)
                  .border(Color.black, width: 1)
                  .foregroundStyle(Color.black)
              }
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            
            Rectangle()
              .position(barPoint)
              .frame(width: buttonWidth, height: 2)
              .foregroundColor(.blue)
          }
          
          TextField("검색어를 입력해주세요.", text: $searchText)
            .submitLabel(.search)
            .onChange(of: searchText) { text in
              // returnKey 누르지 않고 처리
              store.send(.searchTextDidChange(text))
            }
            .onSubmit {
              // returnKey 누른 후 처리
              store.send(.searchTextDidChange(searchText))
            }
            .padding()
            .border(Color.black, width: 1)
          
          ScrollView {
            LazyVStack {
              ForEach(viewStore.state.profile) { profile in
                ProfileView(
                  store: Store(initialState: ProfileFeature.State(profile: profile)) {
                    ProfileFeature()
                  }
                )
              }
            }
          }
        }
      }
    }
  }
}

#Preview {
  GitHubMainView(
    store: Store(initialState: GitHubMainFeature.State(searchText: "", selectedTab: .api)) {
      GitHubMainFeature()
    }
  )
}
