//
//  SearchFeatureTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 24.06.26.
//

import XCTest
import ComposableArchitecture
@testable import NetflixProject
@testable import Storage
internal import OrderedCollections

@MainActor
final class SearchFeatureTests: XCTestCase {

    func test_searchTextBinding_afterDebounce_executesSearchAndShowsResults() async {
        let clock = TestClock()
        let response = [MockMediaDTO.make(id: "1")]

        let searchService = SearchServiceMock()
        searchService.searchHandler = { query, page, type in
            XCTAssertEqual(query, "Batman")
            XCTAssertEqual(page, 1)
            XCTAssertEqual(type, .multi)
            return response
        }

        let store = TestStore(
            initialState: SearchFeature.State()
        ) {
            SearchFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.searchService = searchService
        }

        await store.send(.binding(.set(\.searchText, "Batman"))) {
            $0.searchText = "Batman"
            $0.isLoading = true
        }

        await clock.advance(by: .seconds(2))

        await store.receive(.executeSearch)

        await store.receive(.mediaResponse(response)) {
            $0.searchResults = response
            $0.isLoading = false
        }
    }

    func test_searchTextBinding_whenEmpty_clearsResultsAndCancelsSearch() async {
        let model = MockMediaDTO.make(id: "1")

        let store = TestStore(
            initialState: SearchFeature.State(
                searchText: "Batman",
                isLoading: true,
                searchResults: [model]
            )
        ) {
            SearchFeature()
        }

        await store.send(.binding(.set(\.searchText, ""))) {
            $0.searchText = ""
            $0.searchResults = []
            $0.isLoading = false
        }
    }

    func test_crossButtonTapped_clearsSearchTextResultsAndStopsLoading() async {
        let model = MockMediaDTO.make(id: "1")

        let store = TestStore(
            initialState: SearchFeature.State(
                searchText: "Batman",
                isLoading: true,
                searchResults: [model]
            )
        ) {
            SearchFeature()
        }

        await store.send(.crossButtonTapped) {
            $0.searchText = ""
            $0.searchResults = []
            $0.isLoading = false
        }
    }

    func test_onSubmitTapped_performsSearchImmediately() async {
        let response = [MockMediaDTO.make(id: "1")]

        let searchService = SearchServiceMock()
        searchService.searchHandler = { query, page, type in
            XCTAssertEqual(query, "Batman")
            XCTAssertEqual(page, 1)
            XCTAssertEqual(type, .multi)
            return response
        }

        let store = TestStore(
            initialState: SearchFeature.State(
                searchText: "Batman"
            )
        ) {
            SearchFeature()
        } withDependencies: {
            $0.searchService = searchService
        }

        await store.send(.onSubmitTapped) {
            $0.isLoading = true
            $0.searchResults = []
        }

        await store.receive(.mediaResponse(response)) {
            $0.searchResults = response
            $0.isLoading = false
        }
    }

    func test_executeSearch_resetsPageAndResultsThenPerformsSearch() async {
        let oldModel = MockMediaDTO.make(id: "old")
        let newModel = MockMediaDTO.make(id: "new")

        let searchService = SearchServiceMock()
        searchService.searchHandler = { query, page, type in
            XCTAssertEqual(query, "Batman")
            XCTAssertEqual(page, 1)
            XCTAssertEqual(type, .multi)
            return [newModel]
        }

        let store = TestStore(
            initialState: SearchFeature.State(
                page: 3,
                searchText: "Batman",
                isLoading: false,
                searchResults: [oldModel]
            )
        ) {
            SearchFeature()
        } withDependencies: {
            $0.searchService = searchService
        }

        await store.send(.executeSearch) {
            $0.searchResults = []
            $0.page = 1
            $0.isLoading = true
        }

        await store.receive(.mediaResponse([newModel])) {
            $0.searchResults = [newModel]
            $0.isLoading = false
        }
    }

    func test_searchFailure_showsErrorAlert() async {
        struct TestError: LocalizedError {
            var errorDescription: String? {
                "Something went wrong"
            }
        }

        let searchService = SearchServiceMock()
        searchService.searchHandler = { _, _, _ in
            throw TestError()
        }

        let store = TestStore(
            initialState: SearchFeature.State(
                searchText: "Batman"
            )
        ) {
            SearchFeature()
        } withDependencies: {
            $0.searchService = searchService
        }

        await store.send(.executeSearch) {
            $0.searchResults = []
            $0.page = 1
            $0.isLoading = true
        }

        await store.receive(.showErrorAlert(message: "Something went wrong")) {
            $0.isLoading = false
            $0.destination = .alert(
                AlertState<SearchFeature.Destination.Alert> {
                    TextState(L10n.mainSearchErrorAlertTitle)
                } actions: {
                    ButtonState(action: .tryAgain) {
                        TextState(L10n.mainSearchErrorAlertTryAgainTitle)
                    }
                    ButtonState(role: .cancel) {
                        TextState(L10n.mainSearchErrorAlertTryCancelTitle)
                    }
                } message: {
                    TextState("Something went wrong")
                }
            )
        }
    }

    func test_tryAgainFromAlert_performsSearchAgain() async {
        let response = [MockMediaDTO.make(id: "1")]

        let searchService = SearchServiceMock()
        searchService.searchHandler = { query, page, type in
            XCTAssertEqual(query, "Batman")
            XCTAssertEqual(page, 1)
            XCTAssertEqual(type, .multi)
            return response
        }

        let store = TestStore(
            initialState: SearchFeature.State(
                destination: .alert(
                    AlertState<SearchFeature.Destination.Alert> {
                        TextState(L10n.mainSearchErrorAlertTitle)
                    } actions: {
                        ButtonState(action: .tryAgain) {
                            TextState(L10n.mainSearchErrorAlertTryAgainTitle)
                        }
                    } message: {
                        TextState("Error")
                    }
                ),
                searchText: "Batman"
            )
        ) {
            SearchFeature()
        } withDependencies: {
            $0.searchService = searchService
        }

        await store.send(.destination(.presented(.alert(.tryAgain)))) {
            $0.destination = nil
            $0.isLoading = true
            $0.searchResults = []
        }

        await store.receive(.mediaResponse(response)) {
            $0.searchResults = response
            $0.isLoading = false
        }
    }

    func test_filterButtonTapped_opensFilterScreen() async {
        let store = TestStore(
            initialState: SearchFeature.State(
                selectedType: .multi
            )
        ) {
            SearchFeature()
        }

        await store.send(.filterButtonTapped) {
            $0.destination = .filter(
                FilterFeature.State(
                    selectedType: .multi
                )
            )
        }
    }

    func test_selectTypeFromFilter_updatesSelectedTypeAndPerformsSearch() async {
        let response = [MockMediaDTO.make(id: "1")]

        let searchService = SearchServiceMock()
        searchService.searchHandler = { query, page, type in
            XCTAssertEqual(query, "Batman")
            XCTAssertEqual(page, 1)
            XCTAssertEqual(type, .movie)
            return response
        }

        let store = TestStore(
            initialState: SearchFeature.State(
                destination: .filter(
                    FilterFeature.State(selectedType: .movie)
                ),
                selectedType: .movie,
                searchText: "Batman"
            )
        ) {
            SearchFeature()
        } withDependencies: {
            $0.searchService = searchService
        }

        await store.send(.destination(.presented(.filter(.selectType(.movie))))) {
            $0.selectedType = .movie
            $0.isLoading = true
            $0.searchResults = []
        }

        await store.receive(.mediaResponse(response)) {
            $0.searchResults = response
            $0.isLoading = false
        }
    }

    func test_itemTapped_opensDetailsAndRemovesFocus() async {
        let model = MockMediaDTO.make(id: "1")

        let store = TestStore(
            initialState: SearchFeature.State(
                focus: .search
            )
        ) {
            SearchFeature()
        }

        await store.send(.itemTapped(model)) {
            $0.focus = nil
            $0.path.append(
                .details(
                    DetailsFeature.State(model: model)
                )
            )
        }
    }

    func test_detailsItemTapped_pushesNewDetailsScreen() async {
        let firstModel = MockMediaDTO.make(id: "1")
        let secondModel = MockMediaDTO.make(id: "2")

        let store = TestStore(
            initialState: SearchFeature.State(
                path: StackState([
                    .details(
                        DetailsFeature.State(model: firstModel)
                    )
                ])
            )
        ) {
            SearchFeature()
        }

        let id = store.state.path.ids[0]

        await store.send(.path(.element(id: id, action: .details(.itemTapped(secondModel))))) {
            $0.path.append(
                .details(
                    DetailsFeature.State(model: secondModel)
                )
            )
        }
    }
}

extension SearchFeature.State: @retroactive Equatable {

    public static func == (
        lhs: SearchFeature.State,
        rhs: SearchFeature.State
    ) -> Bool {
        lhs.destination == rhs.destination &&
        lhs.page == rhs.page &&
        lhs.selectedType == rhs.selectedType &&
        lhs.searchText == rhs.searchText &&
        lhs.isLoading == rhs.isLoading &&
        lhs.searchResults.map(\.id) == rhs.searchResults.map(\.id) &&
        lhs.focus == rhs.focus &&
        lhs.path.count == rhs.path.count
    }
}

extension SearchFeature.Action: @retroactive Equatable {

    public static func == (
        lhs: SearchFeature.Action,
        rhs: SearchFeature.Action
    ) -> Bool {
        switch (lhs, rhs) {

        case (.executeSearch, .executeSearch):
            return true

        case (.onSubmitTapped, .onSubmitTapped):
            return true

        case (.crossButtonTapped, .crossButtonTapped):
            return true

        case (.filterButtonTapped, .filterButtonTapped):
            return true

        case let (.mediaResponse(lhsModels), .mediaResponse(rhsModels)):
            return lhsModels.map(\.id) == rhsModels.map(\.id)

        case let (.showErrorAlert(lhsMessage), .showErrorAlert(rhsMessage)):
            return lhsMessage == rhsMessage

        case let (.itemTapped(lhsModel), .itemTapped(rhsModel)):
            return lhsModel.id == rhsModel.id

        default:
            return false
        }
    }
}
