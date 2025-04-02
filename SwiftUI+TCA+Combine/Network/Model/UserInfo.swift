//
//	UserInfo.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct UserInfo: Codable {
	let incompleteResults: Bool?
	var profile: [Profile]?
	let totalCount: Int?
    
    enum codingKeys: String, CodingKey {
        case incompleteResults = "incomplete_results"
        case profile = "items"
        case totalCount = "total_count"
    }
    
    init(incompleteResults: Bool?, profile: [Profile]?, totalCount: Int?) {
        self.incompleteResults = incompleteResults
        self.profile = profile
        self.totalCount = totalCount
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: codingKeys.self)
        incompleteResults = try values.decodeIfPresent(Bool.self, forKey: .incompleteResults) ?? false
        profile = try values.decodeIfPresent([Profile].self, forKey: .profile) ?? []
        totalCount = try values.decodeIfPresent(Int.self, forKey: .totalCount) ?? 0
    }
}
