//
//  ProfileFeatureTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 30.06.26.
//

import XCTest
import ComposableArchitecture
@testable import NetflixProject
@testable import Storage
internal import OrderedCollections

@MainActor
final class ProfileFeatureTests: XCTestCase {

    func test_onAppear_setsThemeUserDataAndLoadsCounts() async {
        let authService = AuthServiceMock()
        authService.currentUserEmailResult = "egor@gmail.com"
        authService.currentUserNameResult = "Egor"

        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        } withDependencies: {
            $0.authService = authService

            $0.themeService.getTheme = {
                .dark
            }

            $0.mediaStorage.counts = {
                (favorites: 3, bookmarked: 5)
            }

            $0.mediaDataWorker.waitingsCount = {
                7
            }
        }

        await store.send(ProfileFeature.Action.onAppear) {
            $0.selectedTheme = .dark
            $0.email = "egor@gmail.com"
            $0.name = "Egor"
        }

        await store.receive(
            ProfileFeature.Action.countsLoaded(
                favorites: 3,
                bookmarked: 5,
                waitings: 7
            )
        ) {
            $0.favoritesCount = 3
            $0.markedCount = 5
            $0.waitingsCount = 7
        }
    }

    func test_onAppear_whenUserNameIsNil_setsGuest() async {
        let authService = AuthServiceMock()
        authService.currentUserEmailResult = nil
        authService.currentUserNameResult = nil

        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        } withDependencies: {
            $0.authService = authService

            $0.themeService.getTheme = {
                .system
            }

            $0.mediaStorage.counts = {
                (favorites: 0, bookmarked: 0)
            }

            $0.mediaDataWorker.waitingsCount = {
                0
            }
        }

        await store.send(ProfileFeature.Action.onAppear) {
            $0.selectedTheme = .system
            $0.email = ""
            $0.name = "Guest"
        }

        await store.receive(
            ProfileFeature.Action.countsLoaded(
                favorites: 0,
                bookmarked: 0,
                waitings: 0
            )
        )
    }

    func test_selectedThemeBinding_setsThemeAndAppliesThemeIcon() async {
        var receivedThemeForSetTheme: AppTheme?
        var receivedThemeForApplyIcon: AppTheme?

        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        } withDependencies: {
            $0.themeService.setTheme = { theme in
                receivedThemeForSetTheme = theme
            }

            $0.themeService.applyThemeIcon = { theme in
                receivedThemeForApplyIcon = theme
            }
        }

        await store.send(
            ProfileFeature.Action.binding(
                .set(
                    \.selectedTheme,
                     .dark
                )
            )
        ) {
            $0.selectedTheme = .dark
        }

        XCTAssertEqual(receivedThemeForSetTheme, .dark)
        XCTAssertEqual(receivedThemeForApplyIcon, .dark)
    }

    func test_favoritesTapped_setsOpenFavoriteTrigger() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(ProfileFeature.Action.favoritesTapped) {
            $0.openFavoriteTrigger = true
        }
    }

    func test_waitingsTapped_opensNotificationsScreen() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(ProfileFeature.Action.waitingsTapped) {
            $0.path.append(
                .notifications(
                    NotificationsFeature.State()
                )
            )
        }
    }

    func test_markedTapped_opensBookmarksScreen() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(ProfileFeature.Action.markedTapped) {
            $0.path.append(
                .bookmark(
                    BookmarksFeature.State()
                )
            )
        }
    }

    func test_notificationsTapped_opensNotificationsScreen() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(ProfileFeature.Action.notificationsTapped) {
            $0.path.append(
                .notifications(
                    NotificationsFeature.State()
                )
            )
        }
    }

    func test_mailDismissed_setsOpenMailTriggerFalse() async {
        let store = TestStore(
            initialState: ProfileFeature.State(
                openMailTrigger: true
            )
        ) {
            ProfileFeature()
        }

        await store.send(ProfileFeature.Action.mailDismissed) {
            $0.openMailTrigger = false
        }
    }

    func test_countsLoaded_updatesCounts() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(
            ProfileFeature.Action.countsLoaded(
                favorites: 10,
                bookmarked: 20,
                waitings: 30
            )
        ) {
            $0.favoritesCount = 10
            $0.markedCount = 20
            $0.waitingsCount = 30
        }
    }

    func test_showErrorAlert_setsAlertDestination() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(
            ProfileFeature.Action.showErrorAlert(
                message: "Something went wrong"
            )
        ) {
            $0.destination = .alert(
                AlertState<ProfileFeature.Destination.Alert> {
                    TextState(L10n.mainSearchErrorAlertTitle)
                } actions: {
                    ButtonState(action: .tryAgain) {
                        TextState(L10n.mainSearchErrorAlertTryAgainTitle)
                    }
                } message: {
                    TextState("Something went wrong")
                }
            )
        }
    }

    func test_logoutButtonTapped_whenSuccess_sendsUserDidLogoutDelegate() async {
        var logoutCalled = false
        var signOutCalled = false

        let authService = AuthServiceMock()
        authService.signOutHandler = {
            signOutCalled = true
        }

        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        } withDependencies: {
            $0.authService = authService

            $0.mediaDataWorker.logout = {
                logoutCalled = true
            }
        }

        await store.send(ProfileFeature.Action.logoutButtonTapped)

        await store.receive(ProfileFeature.Action.delegate(.userDidLogout)) {
            $0.isLoggedOut = true
        }

        XCTAssertTrue(logoutCalled)
        XCTAssertTrue(signOutCalled)
    }

    func test_logoutButtonTapped_whenSignOutFails_showsErrorAlert() async {
        struct TestError: LocalizedError {
            var errorDescription: String? {
                "Logout failed"
            }
        }

        let authService = AuthServiceMock()
        authService.signOutHandler = {
            throw TestError()
        }

        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        } withDependencies: {
            $0.authService = authService

            $0.mediaDataWorker.logout = {}
        }

        await store.send(ProfileFeature.Action.logoutButtonTapped)

        await store.receive(
            ProfileFeature.Action.showErrorAlert(
                message: "Logout failed"
            )
        ) {
            $0.destination = .alert(
                AlertState<ProfileFeature.Destination.Alert> {
                    TextState(L10n.mainSearchErrorAlertTitle)
                } actions: {
                    ButtonState(action: .tryAgain) {
                        TextState(L10n.mainSearchErrorAlertTryAgainTitle)
                    }
                } message: {
                    TextState("Logout failed")
                }
            )
        }
    }

    func test_tryAgainFromAlert_retriesLogout() async {
        var logoutCallCount = 0
        var signOutCallCount = 0

        let authService = AuthServiceMock()
        authService.signOutHandler = {
            signOutCallCount += 1
        }

        let store = TestStore(
            initialState: ProfileFeature.State(
                destination: .alert(
                    AlertState<ProfileFeature.Destination.Alert> {
                        TextState(L10n.mainSearchErrorAlertTitle)
                    } actions: {
                        ButtonState(action: .tryAgain) {
                            TextState(L10n.mainSearchErrorAlertTryAgainTitle)
                        }
                    } message: {
                        TextState("Error")
                    }
                )
            )
        ) {
            ProfileFeature()
        } withDependencies: {
            $0.authService = authService

            $0.mediaDataWorker.logout = {
                logoutCallCount += 1
            }
        }

        await store.send(
            ProfileFeature.Action.destination(
                .presented(
                    .alert(
                        .tryAgain
                    )
                )
            )
        ) {
            $0.destination = nil
        }

        await store.receive(ProfileFeature.Action.delegate(.userDidLogout)) {
            $0.isLoggedOut = true
        }

        XCTAssertEqual(logoutCallCount, 1)
        XCTAssertEqual(signOutCallCount, 1)
    }

    func test_delegateUserDidLogout_setsIsLoggedOutTrue() async {
        let store = TestStore(
            initialState: ProfileFeature.State()
        ) {
            ProfileFeature()
        }

        await store.send(ProfileFeature.Action.delegate(.userDidLogout)) {
            $0.isLoggedOut = true
        }
    }

    func test_detailsItemTappedFromDetails_pushesNewDetailsScreen() async {
        let firstModel = MockMediaDTO.make(id: "1")
        let secondModel = MockMediaDTO.make(id: "2")

        let store = TestStore(
            initialState: ProfileFeature.State(
                path: StackState([
                    .details(
                        DetailsFeature.State(model: firstModel)
                    )
                ])
            )
        ) {
            ProfileFeature()
        }

        let id = store.state.path.ids[0]

        await store.send(
            ProfileFeature.Action.path(
                .element(
                    id: id,
                    action: .details(.itemTapped(secondModel))
                )
            )
        ) {
            $0.path.append(
                .details(
                    DetailsFeature.State(model: secondModel)
                )
            )
        }
    }

    func test_itemSelectedFromBookmarks_pushesDetailsScreen() async {
        let model = MockMediaDTO.make(id: "1")

        let store = TestStore(
            initialState: ProfileFeature.State(
                path: StackState([
                    .bookmark(
                        BookmarksFeature.State()
                    )
                ])
            )
        ) {
            ProfileFeature()
        }

        let id = store.state.path.ids[0]

        await store.send(
            ProfileFeature.Action.path(
                .element(
                    id: id,
                    action: .bookmark(.itemSelected(model))
                )
            )
        ) {
            $0.path.append(
                .details(
                    DetailsFeature.State(model: model)
                )
            )
        }
    }

    func test_itemSelectedFromNotifications_pushesDetailsScreen() async {
        let model = MockMediaDTO.make(id: "1")

        let store = TestStore(
            initialState: ProfileFeature.State(
                path: StackState([
                    .notifications(
                        NotificationsFeature.State()
                    )
                ])
            )
        ) {
            ProfileFeature()
        }

        let id = store.state.path.ids[0]

        await store.send(
            ProfileFeature.Action.path(
                .element(
                    id: id,
                    action: .notifications(.itemSelected(model))
                )
            )
        ) {
            $0.path.append(
                .details(
                    DetailsFeature.State(model: model)
                )
            )
        }
    }
}

extension ProfileFeature.State: @retroactive Equatable {

    public static func == (
        lhs: ProfileFeature.State,
        rhs: ProfileFeature.State
    ) -> Bool {
        lhs.destination == rhs.destination &&
        lhs.selectedTheme == rhs.selectedTheme &&
        lhs.email == rhs.email &&
        lhs.name == rhs.name &&
        lhs.favoritesCount == rhs.favoritesCount &&
        lhs.waitingsCount == rhs.waitingsCount &&
        lhs.markedCount == rhs.markedCount &&
        lhs.isLoggedOut == rhs.isLoggedOut &&
        lhs.openFavoriteTrigger == rhs.openFavoriteTrigger &&
        lhs.openMailTrigger == rhs.openMailTrigger &&
        lhs.path.count == rhs.path.count
    }
}

extension ProfileFeature.Action: @retroactive Equatable {

    public static func == (
        lhs: ProfileFeature.Action,
        rhs: ProfileFeature.Action
    ) -> Bool {
        switch (lhs, rhs) {

        case (.favoritesTapped, .favoritesTapped):
            return true

        case (.waitingsTapped, .waitingsTapped):
            return true

        case (.markedTapped, .markedTapped):
            return true

        case (.notificationsTapped, .notificationsTapped):
            return true

        case (.rateAppTapped, .rateAppTapped):
            return true

        case (.supportTapped, .supportTapped):
            return true

        case (.logoutButtonTapped, .logoutButtonTapped):
            return true

        case (.onAppear, .onAppear):
            return true

        case (.mailDismissed, .mailDismissed):
            return true

        case let (
            .countsLoaded(lhsFavorites, lhsBookmarked, lhsWaitings),
            .countsLoaded(rhsFavorites, rhsBookmarked, rhsWaitings)
        ):
            return lhsFavorites == rhsFavorites &&
            lhsBookmarked == rhsBookmarked &&
            lhsWaitings == rhsWaitings

        case let (.showErrorAlert(lhsMessage), .showErrorAlert(rhsMessage)):
            return lhsMessage == rhsMessage

        case (.delegate(.userDidLogout), .delegate(.userDidLogout)):
            return true

        case (.delegate(.openFavorites), .delegate(.openFavorites)):
            return true

        default:
            return false
        }
    }
}
