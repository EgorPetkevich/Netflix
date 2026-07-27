//
//  ProfileFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import Foundation
import ComposableArchitecture
import Storage
import StoreKit
import MessageUI

@Reducer
struct ProfileFeature {

    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
        var path = StackState<Path.State>()
        var selectedTheme: AppTheme = .system

        var email: String = ""
        var name: String = ""

        var favoritesCount: Int = 0
        var waitingsCount: Int = 0
        var markedCount: Int = 0

        var isLoggedOut: Bool = false
        var openFavoriteTrigger: Bool = false
        var openMailTrigger: Bool = false
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case destination(PresentationAction<Destination.Action>)
        case path(StackAction<Path.State, Path.Action>)
        case favoritesTapped
        case waitingsTapped
        case markedTapped
        case notificationsTapped
        case rateAppTapped
        case supportTapped
        case logoutButtonTapped
        case onAppear
        case mailDismissed
        case countsLoaded(favorites: Int, bookmarked: Int, waitings: Int)
        case showErrorAlert(message: String)
        case delegate(Delegate)

        enum Delegate {
            case userDidLogout
            case openFavorites
        }
    }

    @Reducer
    enum Path {
        case bookmark(BookmarksFeature)
        case notifications(NotificationsFeature)
        case details(DetailsFeature)
    }

    @Reducer
    enum Destination {
        case alert(AlertState<Alert>)

        @CasePathable
        enum Alert: Equatable { case tryAgain }
    }

    @Dependency(\.themeService) var themeService
    @Dependency(\.authService) var authService
    @Dependency(\.mediaStorage) var storage
    @Dependency(\.mediaDataWorker) var dataWorker

    private let looger = Logger(ProfileFeature.self)

    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                state.selectedTheme = themeService.getTheme()

                state.email = authService.currentUserEmail ?? ""
                state.name = authService.currentUserName ?? "Guest"
                return fetchCounts()

            case .binding(\.selectedTheme):
                themeService.setTheme(state.selectedTheme)

                return .run { [theme = state.selectedTheme, themeService] _ in
                    await themeService.applyThemeIcon(theme)
                }

            case .favoritesTapped:
                state.openFavoriteTrigger = true
                return .none

            case .waitingsTapped:
                state.path.append(.notifications(.init()))
                return .none

            case .markedTapped:
                state.path.append(.bookmark(.init()))
                return .none

            case .notificationsTapped:
                state.path.append(.notifications(.init()))
                return .none

            case .rateAppTapped:
                SKStoreReviewController.requestReview()
                return .none

            case .supportTapped:
                if MFMailComposeViewController.canSendMail() {
                    state.openMailTrigger = true
                } else {
                    state.destination = .alert(AlertState<Destination.Alert> {
                        TextState("Mail is not available")
                    } actions: {
                        ButtonState(action: .tryAgain) {
                            TextState("OK")
                        }
                    } message: {
                        TextState("Please configure Mail app on your device.")
                    })
                }
                return .none

            case .mailDismissed:
                state.openMailTrigger = false
                return .none

            case .logoutButtonTapped:
                return self.logOut(state: &state)

            case let .countsLoaded(favorites, bookmarked, waitings):
                state.favoritesCount = favorites
                state.markedCount = bookmarked
                state.waitingsCount = waitings
                return .none

            case let .showErrorAlert(message):
                state.destination = .alert(AlertState<Destination.Alert> {
                    TextState(L10n.mainSearchErrorAlertTitle)
                } actions: {
                    ButtonState(action: .tryAgain) { TextState(L10n.mainSearchErrorAlertTryAgainTitle) }
                } message: {
                    TextState(message)
                })
                return .none

            case .destination(.presented(.alert(.tryAgain))):
                return self.logOut(state: &state)

            case .delegate(.userDidLogout):
                state.isLoggedOut = true
                return .none

            case let .path(.element(id: _, action: .details(.itemTapped(model)))):
                state.path.append(.details(DetailsFeature.State(model: model)))
                return .none

            case let .path(.element(id: _, action: .bookmark(.itemSelected(model)))):
                state.path.append(.details(DetailsFeature.State(model: model)))
                return .none

            case let .path(.element(id: _, action: .notifications(.itemSelected(model)))):
                state.path.append(.details(DetailsFeature.State(model: model)))
                return .none

            case .path(.popFrom):
                return fetchCounts()

            case .destination, .binding, .delegate(.openFavorites), .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$destination, action: \.destination)
    }

    func logOut(state: inout State) -> Effect<Action> {
        return .run { [authService] send in
            do {
                await dataWorker.logout()
                try authService.signOut()

                UDManager.set(.authenticated, value: false)
                await send(.delegate(.userDidLogout))
            } catch {
                await send(.showErrorAlert(message: error.localizedDescription))
            }
        }
    }

    func fetchCounts() -> Effect<Action> {
        .run { [storage, dataWorker] send in
            do {
                let result = try await storage.counts()
                let waitingsCount = await dataWorker.waitingsCount()

                await send(.countsLoaded(
                    favorites: result.favorites,
                    bookmarked: result.bookmarked,
                    waitings: waitingsCount
                ))
            } catch {
                looger.error(error.localizedDescription)
            }
        }
    }
}

extension ProfileFeature.Destination.State: Equatable {}
