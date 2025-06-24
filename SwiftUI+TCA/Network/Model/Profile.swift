//
//	Profile.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct Profile: Codable, Identifiable, Equatable {
  var id = UUID()
  var initial: String = ""        // 초성(즐겨찾기용)
  let userName: String?		        // 사용자 이름
  let profileURL: String?         // 프로필 이미지 URL
  let repositoryURL: String       // 사용자 URL
  var isFavorite: Bool = false    // 즐겨찾기 여부
  
  enum CodingKeys: String, CodingKey {
    case userName = "login"
    case profileURL = "avatar_url"
    case repositoryURL = "html_url"
  }
  
  static let empty = Profile(userName: "", profileURL: "", repositoryURL: "")
  static let preview = Profile(
    initial: "T",
    userName: "TestUser",
    profileURL: "https://avatars.githubusercontent.com/u/14283190?v=4",
    repositoryURL: "https://github.com/jeonbonggil"
  )
  
  init(
    initial: String = "",
    userName: String? = nil,
    profileURL: String? = nil,
    repositoryURL: String = "",
    isFavorite: Bool = false
  ) {
    self.initial = initial
    self.userName = userName
    self.profileURL = profileURL
    self.repositoryURL = repositoryURL
    self.isFavorite = isFavorite
  }
}
