//
//  Profile.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/1/25.
//

import Foundation

struct Profile: Identifiable, Equatable {
    var id: ObjectIdentifier
    
    let initial: String?
    let imageURL: String?
    let userName: String?
    var isFavorite = false
}
