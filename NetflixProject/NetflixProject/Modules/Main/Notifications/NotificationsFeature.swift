//
//  NotificationsFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import Foundation
import ComposableArchitecture
import Storage

@Reducer
struct NotificationsFeature {

    @ObservableState
    struct State {
        var selectedTab: NotificationTab = .waitings
        var filteredItems: [MovieDTO] = []

        var waitings: [MovieDTO] = []
        var delivered: [MovieDTO] = []
    }

    enum Action {
        case itemSelected(any MediaDTODescription)
        case onAppear
        case backButtonTapped
        case tabSelected(NotificationTab)

        case fetch(waitings: [MovieDTO], delivered: [MovieDTO])
    }

    @Reducer
    enum Path {
        case details(DetailsFeature)
    }

    @Dependency(\.mediaDataWorker) var dataWorker
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {

            case .itemSelected:
                return .none

            case .backButtonTapped:
                return .run { _ in await self.dismiss() }

            case let .tabSelected(tab):
                state.selectedTab = tab

                switch tab {
                case .waitings:
                    state.filteredItems = state.waitings

                case .delivered:
                    state.filteredItems = state.delivered
                }

                return .none

            case .onAppear:
                return .run { send in
                    let waitings = await dataWorker.getWaitings()
                    let delivered = await dataWorker.getDelivered()

                    await send(
                        .fetch(
                            waitings: waitings,
                            delivered: delivered
                        )
                    )
                }

            case let .fetch(waitings, delivered):
                state.waitings = waitings
                state.delivered = delivered

                switch state.selectedTab {
                case .waitings:
                    state.filteredItems = waitings

                case .delivered:
                    state.filteredItems = delivered
                }

                return .none
            }
        }
    }

}
