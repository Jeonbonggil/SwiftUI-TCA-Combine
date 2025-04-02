//
//  ProfileFeature.swift
//  SwiftUI+TCA+Combine
//
//  Created by ec-jbg on 4/1/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct ProfileFeature {
    struct State: Equatable {
        var profile: Profile = .empty
    }
    
    enum Action: Equatable {
        case favoriteButtonTapped
    }
    
    struct Environment {
        var mainQueue: AnySchedulerOf<DispatchQueue>
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .favoriteButtonTapped:
                state.profile.isFavorite.toggle()
                return .none
            }
            
        }
    }
}
