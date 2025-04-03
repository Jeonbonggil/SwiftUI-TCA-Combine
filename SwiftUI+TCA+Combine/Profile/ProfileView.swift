//
//  ProfileView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/24/25.
//

import Combine
import ComposableArchitecture
import Kingfisher
import SwiftUI

struct ProfileView: View {
  let store: StoreOf<ProfileFeature>
  private let imageSize = 60.0
  private let starSzie = 30.0
  
  var body: some View {
    WithViewStore(store, observe: { $0.profile }) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        Text(viewStore.initial)
          .font(.system(size: 17.0, weight: .bold))
          .foregroundColor(Color.black)
          .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
          .frame(maxWidth: Screen.width, alignment: .leading)
        
        HStack(alignment: .center, spacing: 0) {
          if let imageUrl = viewStore.profileURL {
            KFImage(URL(string: imageUrl))
              .resizable()
              .scaledToFill()
              .frame(width: imageSize, height: imageSize)
              .border(Color.black, width: 1)
              .cornerRadius(imageSize / 2)
          } else {
            Image(systemName: "person.circle.fill")
              .resizable()
              .frame(width: imageSize, height: imageSize)
              .foregroundStyle(Color(.systemGray4))
          }
          
          Text(viewStore.userName ?? "")
            .font(.system(size: 17.0))
            .foregroundColor(Color.black)
            .lineLimit(2)
            .padding(EdgeInsets(top: 0, leading: 19, bottom: 0, trailing: 15))
            .frame(maxWidth: .infinity, alignment: .leading)
          
          Image(systemName: viewStore.isFavorite ? "star.fill" : "star")
            .foregroundStyle(Color.blue)
            .frame(width: starSzie, height: starSzie)
            .onTapGesture {
              viewStore.send(.favoriteButtonTapped)
              
              withAnimation {
                // TODO: 즐겨찾기 버튼 클릭 시 애니메이션 추가
              }
            }
        }
        .padding([.leading, .trailing], 15)
        .frame(width: Screen.width, alignment: .leading)
      }
      .frame(width: Screen.width, height: 105.0)
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
