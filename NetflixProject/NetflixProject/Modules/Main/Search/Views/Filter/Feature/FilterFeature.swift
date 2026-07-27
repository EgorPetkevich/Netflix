//
//  FilterFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct FilterFeature {

    @ObservableState
    struct State: Equatable {
        var selectedType: SearchType = .multi
    }

    enum Action: Equatable {
        case selectType(SearchType)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .selectType(type):
                state.selectedType = type
                return .none
            }
        }
    }
}
