//
//	UserInfo.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation

struct UserInfo: Codable {
	let incomplete_results: Bool
	var profile: [Profile]
	let total_count: Int
}
