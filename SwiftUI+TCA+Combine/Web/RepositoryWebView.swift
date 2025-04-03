//
//  RepositoryWebView.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/3/25.
//

import SwiftUI
import WebKit

struct RepositoryWebView: UIViewRepresentable {
  var url: String = ""
  var webview: WKWebView
  
  init(url: String = "") {
    self.url = url
    self.webview = WKWebView()
  }
  
  func makeUIView(context: Context) -> WKWebView {
    let url = URL(string: url)!
    let urlRequest = URLRequest(url: url)
    webview.load(urlRequest)
    return webview
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
    return
  }
}
