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
  @State private var currentTab: MenuTab = .api
  
  var body: some View {
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
                currentTab = tab
                store.send(.selectedTabDidChange(tab))
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
            store.send(.clearSearchText)
          })
          .submitLabel(.search)
          .onSubmit {
            // Keyboard 검색 Button 클릭 시 검색
            store.send(.searchTextDidChange(localSearchText))
            UIApplication.shared.endEditing()
          }
          .padding()
          .border(.black, width: 1)
        
        ScrollViewReader { proxy in
          WithPerceptionTracking {
            ScrollView {
              LazyVStack(spacing: 0) {
                ForEach(
                  store.scope(state: \.profileFeatures, action: \.profileFeatures)
                ) { profileStore in
                  ProfileView(store: profileStore)
                    .onAppear {
                      // TODO: - 실행 방법을 모르겠음
                      // store.send(.loadMore(index))  // Infinite Scrolling
                    }
                }
              }
            }
            .simultaneousGesture(DragGesture().onChanged { _ in
              // ScrollView에서 Drag 시 Keyboard 내리기
              UIApplication.shared.endEditing()
            })
            .onChange(of: store.searchText) { _ in
              proxy.scrollTo(0, anchor: .top) // 스크롤 최상단으로 이동
            }
            .onChange(of: store.selectedTab) { _ in
              proxy.scrollTo(0, anchor: .top) // 스크롤 최상단으로 이동
            }
            .refreshable {
              store.send(.refreshAPI) // Pull to Refresh
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

#Preview {
  GitHubMainView(
    store: Store(
      initialState: GitHubMainFeature.State(),
      reducer: { GitHubMainFeature() }
    )
  )
}
