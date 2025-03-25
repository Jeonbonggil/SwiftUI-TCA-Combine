//
//  ProfileView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/24/25.
//

import SwiftUI
import Kingfisher

struct Profile {
    let initial: String?
    let profileImageURL: String?
    let userName = ""
    @State var isSelected = false
}

struct ProfileView: View {
    private var imageSize = 60.0
    private var starSzie = 30.0
    var initial = "A"
    var profileImageUrl: String? = nil
    var userName = "김땡땡"
    @State var isSelected = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(initial)
                .font(.system(size: 17.0))
                .foregroundColor(Color.black)
                .bold()
                .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 15))
                .frame(maxWidth: Screen.width, alignment: .leading)
                .border(Color.red, width: 1)
            
            HStack(alignment: .center, spacing: 0) {
                if let imageUrl = profileImageUrl {
                    KFImage(URL(string: imageUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
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
                    .frame(minWidth: 280, alignment: .leading)
                
                Image(systemName: isSelected ? "star.fill" : "star")
                    .foregroundStyle(Color.blue)
                    .frame(width: starSzie, height: starSzie)
                    .onTapGesture {
                        withAnimation {
                            isSelected.toggle()
                        }
                    }
            }
            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            .frame(width: Screen.width, alignment: .leading)
            .border(Color.blue, width: 1)
        }
        .frame(width: Screen.width, height: 105.0)
        .border(Color.black, width: 1)
    }
}

#Preview {
    ProfileView()
}
