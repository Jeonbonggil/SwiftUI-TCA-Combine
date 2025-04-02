//
//  Profile.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/1/25.
//

import Foundation

struct Profile: Identifiable, Equatable {
    var id: UUID = UUID()
    let initial: String?
    let imageURL: String?
    let userName: String?
    var isFavorite = false
    
    static let empty = Profile(initial: "", imageURL: "", userName: "")
}
