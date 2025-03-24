//
//  ProfileView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/24/25.
//

import SwiftUI
import Kingfisher

struct ProfileView: View {
   var imageSize = 60.0
   var starSzie = 30.0
   var initial = "A"
   var profileImageUrl: String? = nil
   var userName = "김땡땡"
   @State var isSelected = false
   
   var body: some View {
      VStack(alignment: .leading) {
         Text(initial)
            .font(.system(size: 17.0))
            .foregroundColor(Color.black)
            .bold()
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
            .frame(maxWidth: Screen.width, alignment: .leading)
         
         HStack(alignment: .center) {
            if let imageUrl = profileImageUrl {
               KFImage(URL(string: imageUrl))
                  .resizable()
                  .scaledToFill()
                  .frame(width: imageSize, height: imageSize)
                  .clipShape(Circle())
                  .padding(0)
            } else {
               Image(systemName: "person.circle.fill")
                  .resizable()
                  .frame(width: imageSize, height: imageSize)
                  .foregroundStyle(Color(.systemGray4))
            }
            
            Text(userName)
               .font(.system(size: 17.0))
               .foregroundColor(Color.black)
               .lineLimit(2)
               .padding(EdgeInsets(top: 0, leading: 19, bottom: 0, trailing: 15))
            
            Image(systemName: isSelected ? "star.fill" : "star")
               .foregroundStyle(Color.blue)
               .frame(width: starSzie, height: starSzie)
               .onTapGesture {
                  withAnimation {
                     isSelected.toggle()
                  }
               }
         }
         .frame(width: Screen.width)
      }
      .frame(width: Screen.width, height: 105.0)
      .padding(0.0)
      .border(Color.black, width: 1)
   }
}

#Preview {
    ProfileView()
}
