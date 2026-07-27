//
//  FavoritesReducer.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 24.04.26.
//

import ComposableArchitecture
import Storage

@Reducer
struct FavoritesFeature {

    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var items: [any MediaDTODescription] = []
        var filteredItems: [any MediaDTODescription] = []
        var selectedFilter: FavoritesFilter = .movies
    }

    enum Action {
        case itemSelected(any MediaDTODescription)
        case filterChanged(FavoritesFilter)
        case onAppear

        case path(StackAction<Path.State, Path.Action>)

        case fetch([any MediaDTODescription])
    }

    @Reducer
    enum Path {
        case details(DetailsFeature)
    }

    @Dependency(\.mediaStorage) var storage

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {

            case let .filterChanged(filter):
                state.selectedFilter = filter
                applyFilter(state: &state)
                return .none

            case let .itemSelected(model):
                state.path.append(.details(.init(model: model)))
                return .none

            case .onAppear:
                return .run { send in
                    let items = await storage.fetch()
                    await send(.fetch(items))
                }

            case let .fetch(response):
                state.items = response
                applyFilter(state: &state)
                return .none

            case let .path(.element(id: _, action: .details(.itemTapped(model)))):
                state.path.append(.details(DetailsFeature.State(model: model)))
                return .none

            case .path(.element(_, action: .details(.likeTapped))):
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    func applyFilter(state: inout State) {
        switch state.selectedFilter {

        case .movies:
            state.filteredItems = state.items
                .compactMap { $0 as? MovieDTO }
                .filter { $0.isFavorite }

        case .tvs:
            state.filteredItems = state.items
                .compactMap { $0 as? TvDTO }
                .filter { $0.isFavorite }

        case .persons:
            state.filteredItems = state.items
                .compactMap { $0 as? PersonDTO }
                .filter { $0.isFavorite }
        }
    }

}
