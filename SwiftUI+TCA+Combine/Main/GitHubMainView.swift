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
                viewStore.send(.searchTextDidChange(searchText))
                viewStore.send(.selectedTabDidChange(.api))
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
                viewStore.send(.selectedTabDidChange(.favorite))
                searchText = ""
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
            .clearButton(text: $searchText, action: {
              searchText = ""
              viewStore.send(.searchTextDidChange(searchText))
            })
            .submitLabel(.search)
            .onChange(of: searchText) { text in
              // 검색어 입력 시 바로 검색
              viewStore.send(.searchTextDidChange(text))
            }
            .padding()
            .border(Color.black, width: 1)
          
          ScrollViewReader { proxy in
            ScrollView {
              LazyVStack(spacing: 0) {
                ForEach(
                  Array(zip(viewStore.state.profile.indices, viewStore.state.profile)),
                  id: \.0
                ) { index, profile in
                  ProfileView(
                    store: Store(initialState: ProfileFeature.State(profile: profile)) {
                      ProfileFeature()
                    }
                  )
                  .onAppear {
                    // Infinite scrolling
//                  print("Profile onAppear index: \(index)")
                    viewStore.send(.loadMore(index))
                  }
                }
              }
            }
            .onChange(of: viewStore.state.selectedTab) { _ in
              proxy.scrollTo(0, anchor: .top)
            }
            .refreshable {
              viewStore.send(.refreshAPI)
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
