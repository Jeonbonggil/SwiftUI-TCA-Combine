//
//  ContentView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/19/25.
//

import ComposableArchitecture
import SwiftUI

struct GitHubMainView: View {
  let store: StoreOf<GitHubMainFeature>
  @State private var localSearchText = ""
  @State private var barPoint = CGPoint(x: 0, y: 0)
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text("Github Stars")
          .font(.title)
          .frame(width: Screen.width, alignment: .leading)
          .padding(EdgeInsets(top: 10, leading: 25, bottom: 20, trailing: 0))
        
        VStack(spacing: 0) {
          ZStack(alignment: .bottom) {
            HStack(spacing: 0) {
              ForEach(MenuTab.allCases, id: \.self) { tab in
                Button {
                  viewStore.send(.selectedTabDidChange(tab))
                  withAnimation {
                    barPoint.x = tab.xOffset
                  }
                } label: {
                  Text(tab.title)
                    .frame(width: tab.menuWidth, height: tab.menuHeight)
                    .border(.black, width: 1)
                    .foregroundStyle(.black)
                }
              }
            }
            .padding(.horizontal, 15)
            
            Rectangle()
              .position(barPoint)
              .frame(width: MenuTab.api.menuWidth, height: 2)
              .foregroundColor(.blue)
          }
          
          TextField("검색어를 입력해주세요.", text: $localSearchText)
            .clearButton(text: $localSearchText, action: {
              localSearchText = ""
              viewStore.send(.clearSearchText)
            })
            .submitLabel(.search)
            .onSubmit {
              // Keyboard 검색 Button 클릭 시 검색
              viewStore.send(.searchTextDidChange(localSearchText))
              UIApplication.shared.endEditing()
            }
            .padding()
            .border(.black, width: 1)
          
          ScrollViewReader { proxy in
            WithPerceptionTracking {
              ScrollView {
                LazyVStack(spacing: 0) {
                  ForEach(
                    Array(zip(viewStore.profile.indices, viewStore.state.profile)),
                    id: \.0
                  ) { index, profile in
                    ProfileView(
                      store: Store(
                        initialState: ProfileFeature.State(
                          // tab: viewStore.selectedTab,
                          profile: profile
                        ),
                        reducer: {
                          ProfileFeature()
                        }
                      )
                    )
                    .onAppear {
                      // Infinite Scrolling
                      // print("Profile onAppear index: \(index)")
                      viewStore.send(.loadMore(index))
                    }
                  }
                }
              }
              .simultaneousGesture(DragGesture().onChanged { _ in
                // ScrollView에서 Drag 시 Keyboard 내리기
                UIApplication.shared.endEditing()
              })
              .onChange(of: viewStore.searchText) { _ in
                proxy.scrollTo(0, anchor: .top) // 스크롤 최상단으로 이동
              }
              .onChange(of: viewStore.selectedTab) { _ in
                proxy.scrollTo(0, anchor: .top) // 스크롤 최상단으로 이동
              }
              .refreshable {
                viewStore.send(.refreshAPI) // Pull to Refresh
              }
            }
          }
        }
      }
      .onTapGesture {
        UIApplication.shared.endEditing()
      }
    }
  }
}

#Preview {
  GitHubMainView(
    store: Store(
      initialState: GitHubMainFeature.State(),
      reducer: { GitHubMainFeature() }
    )
  )
}

// MARK: - Binding 헬퍼 확장

extension ViewStoreOf<GitHubMainFeature> {
  var searchTextBinding: Binding<String> {
    Binding(
      get: { self.searchText },
      set: { self.send(.searchTextDidChange($0)) }
    )
  }
  
  var selectedTabBinding: Binding<MenuTab> {
    Binding(
      get: { self.selectedTab },
      set: { self.send(.selectedTabDidChange($0)) }
    )
  }
}
