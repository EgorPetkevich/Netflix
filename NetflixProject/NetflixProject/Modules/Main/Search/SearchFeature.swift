//
//  SearchFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation
import ComposableArchitecture
import Storage

@Reducer
struct SearchFeature {

    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        var path = StackState<Path.State>()
        var page: Int = 1
        var selectedType: SearchType = .multi
        var searchText: String = ""
        var isLoading: Bool = false
        var searchResults: [any MediaDTODescription] = []
        var focus: Focus? = .search

        enum Focus: Hashable { case search }
    }

    enum Action: BindableAction {
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<Path.State, Path.Action>)
        case executeSearch
        case onSubmitTapped
        case crossButtonTapped
        case filterButtonTapped
        case itemTapped(any MediaDTODescription)
        case mediaResponse([any MediaDTODescription])
        case binding(BindingAction<State>)
        case showErrorAlert(message: String)
    }

    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)
        case filter(FilterFeature)

        @CasePathable
        enum Alert: Equatable { case tryAgain }
    }

    @Reducer
    enum Path {
        case details(DetailsFeature)
    }

    private enum CancelID { case search }

    @Dependency(\.continuousClock) var clock

    @Dependency(\.searchService) var searchService

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce<State, Action> { state, action in
            switch action {

            case .executeSearch:
                state.searchResults = []
                state.page = 1
                return self.performSearch(state: &state)

            case .binding(\.searchText):
                if state.searchText.isEmpty {
                    state.searchResults = []
                    state.isLoading = false
                    return .cancel(id: CancelID.search)
                }

                state.isLoading = true

                return .run { send in
                    try await clock.sleep(for: .seconds(2))
                    await send(.executeSearch)
                }
                .cancellable(id: CancelID.search, cancelInFlight: true)

            case .destination(.presented(.alert(.tryAgain))):
                return self.performSearch(state: &state)

            case let .destination(.presented(.filter(.selectType(type)))):
                state.selectedType = type
                return performSearch(state: &state)

            case let .showErrorAlert(message):
                state.isLoading = false
                state.destination = .alert(AlertState<Destination.Alert> {
                    TextState(L10n.mainSearchErrorAlertTitle)
                } actions: {
                    ButtonState(action: .tryAgain) { TextState(L10n.mainSearchErrorAlertTryAgainTitle) }
                    ButtonState(role: .cancel) { TextState(L10n.mainSearchErrorAlertTryCancelTitle) }
                } message: {
                    TextState(message)
                })
                return .none

            case let .itemTapped(model):
                state.focus = nil
                state.path.append(.details(DetailsFeature.State(model: model)))
                return .none

            case .onSubmitTapped:
                return self.performSearch(state: &state)
                    .cancellable(id: CancelID.search, cancelInFlight: true)

            case .filterButtonTapped:
                state.destination = .filter(
                    FilterFeature.State(
                        selectedType: state.selectedType
                    )
                )
                return .none

            case .crossButtonTapped:
                state.searchText = ""
                state.searchResults = []
                state.isLoading = false
                return .cancel(id: CancelID.search)

            case let .mediaResponse(response):
                state.searchResults.append(contentsOf: response)
                state.isLoading = false
                return .none

            case let .path(.element(id: _, action: .details(.itemTapped(model)))):
                state.path.append(.details(DetailsFeature.State(model: model)))
                return .none

            case .destination, .binding, .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }

    func performSearch(state: inout State) -> Effect<Action> {
        state.isLoading = true
        state.searchResults = []
        let searchText = state.searchText
        let page = state.page

        return .run { [selectedType = state.selectedType] send in
            do {
                let response = try await searchService.search(
                    query: searchText,
                    page: page,
                    type: selectedType
                )
                await send(.mediaResponse(response))
            } catch {
                await send(.showErrorAlert(message: error.localizedDescription))
            }
        }
    }
}

extension SearchFeature.Destination.State: Equatable {}
