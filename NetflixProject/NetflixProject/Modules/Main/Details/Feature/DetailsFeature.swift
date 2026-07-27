//
//  DetailsFeature.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 22.04.26.
//

import ComposableArchitecture
import Storage

@Reducer
struct DetailsFeature {

    @ObservableState
    struct State {
        var model: (any MediaDTODescription)?
        @Presents var destination: Destination.State?
    }

    enum Action {
        case closeButtonTapped
        case likeTapped
        case bookmarkTapped
        case onAppear
        case itemTapped(any MediaDTODescription)
        case updateModel((any MediaDTODescription)?)

        case likeButtonTapped
        case bookmarkButtonTapped
        case premiumChecked(action: PremiumAction, isPremium: Bool)

        case destination(PresentationAction<Destination.Action>)
    }

    enum PremiumAction {
        case like
        case bookmark
    }

    enum CancelID {
        case like
        case bookmark
    }

    @Reducer
    enum Destination {
        case paywall(PaywallFeature)
    }

    @Dependency(\.continuousClock) private var clock
    @Dependency(\.mediaStorage) private var storage
    @Dependency(\.mediaDataWorker) private var dataWorker
    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.purchaseService) private var purchaseService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {

            case .likeButtonTapped:
                return .run { send in
                    let isPremium = await purchaseService.hasActiveSubscription()
                    await send(.premiumChecked(action: .like, isPremium: isPremium))
                }

            case .bookmarkButtonTapped:
                return .run { send in
                    let isPremium = await purchaseService.hasActiveSubscription()
                    await send(.premiumChecked(action: .bookmark, isPremium: isPremium))
                }

            case let .premiumChecked(action, isPremium):
                guard isPremium else {
                    state.destination = .paywall(
                        PaywallFeature.State()
                    )
                    return .none
                }

                switch action {
                case .like:
                    return .send(.likeTapped)
                case .bookmark:
                    return .send(.bookmarkTapped)
                }

            case .destination:
                return .none

            case .onAppear:
                return .run { [model = state.model] send in
                    guard let model else { return }
                    let fetchedModel = await storage.fetchSingle(model.id)
                    await send(.updateModel(fetchedModel))
                }

            case .closeButtonTapped:
                return .run { _ in await dismiss() }

            case .likeTapped:
                state.model?.isFavorite.toggle()

                return .run { [model = state.model] send in
                    guard let model else { return }
                    try await clock.sleep(for: .milliseconds(300))
                    try await dataWorker.updateOrDelete(model)
                    await send(.updateModel(model))
                }
                .cancellable(id: CancelID.like, cancelInFlight: true)

            case .bookmarkTapped:
                state.model?.isBookmarked.toggle()

                return .run { [model = state.model] send in
                    guard let model else { return }
                    try await clock.sleep(for: .milliseconds(300))
                    try await dataWorker.updateOrDelete(model)
                    await send(.updateModel(model))
                }
                .cancellable(id: CancelID.bookmark, cancelInFlight: true)

            case let .updateModel(model):
                if let model {
                    state.model = model
                } else {
                    state.model?.isFavorite = false
                    state.model?.isBookmarked = false
                }
                return .none

            case .itemTapped:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}
