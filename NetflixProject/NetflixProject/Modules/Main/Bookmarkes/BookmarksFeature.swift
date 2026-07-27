//
//  BookmarksFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 30.04.26.
//

import Foundation
import ComposableArchitecture
import Storage

@Reducer
struct BookmarksFeature {

    @ObservableState
    struct State {
        var items: [any MediaDTODescription] = []
    }

    enum Action {
        case itemSelected(any MediaDTODescription)
        case onAppear
        case backButtonTapped

        case fetch([any MediaDTODescription])
    }

    @Reducer
    enum Path {
        case details(DetailsFeature)
    }

    @Dependency(\.mediaStorage) var storage
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {

            case .itemSelected:
                return .none

            case .backButtonTapped:
                return .run { _ in await self.dismiss() }

            case .onAppear:
                return .run { send in
                    let items = await storage.fetch()
                    await send(.fetch(items))
                }

            case let .fetch(response):
                state.items = response.filter { $0.isBookmarked }
                return .none
            }
        }
    }

}
