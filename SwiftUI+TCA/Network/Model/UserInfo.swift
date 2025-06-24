//
//	UserInfo.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct UserInfo: Codable, Equatable {
  let incompleteResults: Bool?
  var profile: [Profile]?
  let totalCount: Int?
  
  enum CodingKeys: String, CodingKey {
    case incompleteResults = "incomplete_results"
    case profile = "items"
    case totalCount = "total_count"
  }
  
  init(incompleteResults: Bool?, profile: [Profile]?, totalCount: Int?) {
    self.incompleteResults = incompleteResults
    self.profile = profile
    self.totalCount = totalCount
  }
  
  static var empty: UserInfo {
    return UserInfo(incompleteResults: false, profile: [], totalCount: 0)
  }
}
