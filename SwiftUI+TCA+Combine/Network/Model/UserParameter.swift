//
//  UserParameter.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/2/25.
//

import Foundation

public struct UserParameters: Equatable {
  var name: String
  var page: Int
  var perPage: Int
  
  init(name: String = "", page: Int = 1, perPage: Int = 30) {
    self.name = name
    self.page = page
    self.perPage = perPage
  }
}
