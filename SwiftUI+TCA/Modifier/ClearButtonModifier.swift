//
//  ClearButtonModifier.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/3/25.
//

import SwiftUI
import UIKit

struct ClearButtonModifier: ViewModifier {
  @Binding var text: String
  var action: () -> Void
  
  func body(content: Content) -> some View {
    HStack {
      content
      if !text.isEmpty {
        Button {
          text = ""
          action()
        } label: {
          Image(systemName: "multiply.circle.fill")
            .foregroundColor(.gray)
        }
        .padding(.trailing, 8)
      }
    }
  }
}

extension View {
  func clearButton(text: Binding<String>, action: @escaping () -> Void) -> some View {
    modifier(ClearButtonModifier(text: text, action: action))
  }
}
