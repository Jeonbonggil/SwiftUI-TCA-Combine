//
//  ProfileFeature.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/1/25.
//

import Foundation
import ComposableArchitecture

struct ProfileFeature: Reducer {
    typealias State = ProfileState
    typealias Action = ProfileAction
    typealias Environment = ProfileEnvironment
    
    struct ProfileState: Equatable {
        let profile: Profile
        var isFavorite = false
    }
    
    enum ProfileAction: Equatable {
        case toggleFavorite
    }
    
    struct ProfileEnvironment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }
    
    var body: some ReducerOf<Self> {
//        Reducer { state, action, environment in
//            switch action {
//            case .toggleFavorite:
//                state.isFavorite.toggle()
//                return .none
//            }
//        }
    }
}
