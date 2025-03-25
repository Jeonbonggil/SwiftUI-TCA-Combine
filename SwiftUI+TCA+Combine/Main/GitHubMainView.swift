//
//  ContentView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 3/19/25.
//

import SwiftUI

struct GitHubMainView: View {
    private let buttonWidth = UIScreen.main.bounds.width / 2
    private let buttonHeight = 50.0
    @State private var barPoint = CGPoint(x: 0, y: 0)
    @State var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Github Stars")
                    .padding(EdgeInsets(top: 0, leading: 15, bottom: 10, trailing: 0))
                
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        HStack(spacing: 0) {
                            Button {
                                withAnimation {
                                    barPoint.x = 0
                                }
                            } label: {
                                Text("API")
                                    .frame(width: buttonWidth, height: buttonHeight)
                                    .border(Color.black, width: 1)
                                    .foregroundStyle(Color.black)
                            }
                            
                            Button {
                                withAnimation {
                                    barPoint.x = buttonWidth
                                }
                            } label: {
                                Text("Local")
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
                        .padding()
                        .border(Color.black, width: 1)
                    
//                    List
                }
            }
        }
    }
}

#Preview {
    GitHubMainView()
}
