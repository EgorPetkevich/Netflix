//
//  DetailsFeatureTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 23.06.26.
//

import XCTest
import ComposableArchitecture
@testable import NetflixProject
@testable import Storage

final class PurchaseServiceMock: PurchaseServiceProtocol {

    func fetchProducts() async throws -> [PurchaseProduct] {
        return []
    }

    func purchase(productId: String) async throws {}

    func restorePurchases() async throws { }

    var hasActiveSubscriptionResult = false

    func hasActiveSubscription() async -> Bool {
        hasActiveSubscriptionResult
    }
}

@MainActor
final class DetailsFeatureTests: XCTestCase {

    func test_onAppear_whenStorageReturnsModel_updatesModel() async {
        let initialModel = TvDTO.mock(
            id: "1",
            isFavorite: false,
            isBookmarked: false
        )

        let storedModel = TvDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true
        )

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: initialModel
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.mediaStorage.fetchSingle = { id in
                XCTAssertEqual(id, "1")
                return storedModel
            }
        }

        await store.send(.onAppear)

        await store.receive(.updateModel(storedModel)) {
            $0.model = storedModel
        }
    }

    func test_onAppear_whenStorageReturnsNil_setsFavoriteAndBookmarkFalse() async {
        let initialModel = TvDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true
        )

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: initialModel
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.mediaStorage.fetchSingle = { id in
                XCTAssertEqual(id, "1")
                return nil
            }
        }

        await store.send(.onAppear)

        await store.receive(.updateModel(nil)) {
            $0.model?.isFavorite = false
            $0.model?.isBookmarked = false
        }
    }

    func test_likeButtonTapped_whenPremiumFalse_showsPaywall() async {
        let model = TvDTO.mock(
            id: "1",
            isFavorite: false
        )

        let purchaseService = PurchaseServiceMock()
        purchaseService.hasActiveSubscriptionResult = false

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: model
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.purchaseService = purchaseService
        }

        await store.send(.likeButtonTapped)

        await store.receive(
            .premiumChecked(
                action: .like,
                isPremium: false
            )
        ) {
            $0.destination = .paywall(
                PaywallFeature.State()
            )
        }
    }

    func test_bookmarkButtonTapped_whenPremiumFalse_showsPaywall() async {
        let model = TvDTO.mock(
            id: "1",
            isBookmarked: false
        )

        let purchaseService = PurchaseServiceMock()
        purchaseService.hasActiveSubscriptionResult = false

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: model
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.purchaseService = purchaseService
        }

        await store.send(.bookmarkButtonTapped)

        await store.receive(
            .premiumChecked(
                action: .bookmark,
                isPremium: false
            )
        ) {
            $0.destination = .paywall(
                PaywallFeature.State()
            )
        }
    }

    func test_bookmarkButtonTapped_whenPremiumTrue_togglesBookmarkAndSavesModel() async {
        let model = TvDTO.mock(
            id: "1",
            isFavorite: false,
            isBookmarked: false
        )

        var expectedModel: any MediaDTODescription = model
        expectedModel.isBookmarked = true

        let purchaseService = PurchaseServiceMock()
        purchaseService.hasActiveSubscriptionResult = true

        let clock = TestClock()
        var savedModel: (any MediaDTODescription)?

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: model
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.purchaseService = purchaseService
            $0.continuousClock = clock

            $0.mediaDataWorker.updateOrDelete = { model in
                savedModel = model
            }
        }

        await store.send(.bookmarkButtonTapped)

        await store.receive(
            .premiumChecked(
                action: .bookmark,
                isPremium: true
            )
        )

        await store.receive(.bookmarkTapped) {
            $0.model?.isBookmarked = true
        }

        await clock.advance(by: .milliseconds(300))

        await store.receive(.updateModel(expectedModel))

        XCTAssertEqual(savedModel?.id, "1")
        XCTAssertEqual(savedModel?.isBookmarked, true)
    }

    func test_likeTapped_twiceQuickly_cancelsPreviousLikeEffectAndSavesOnlyLastState() async {
        let model = TvDTO.mock(
            id: "1",
            isFavorite: false
        )

        var expectedModel: any MediaDTODescription = model
        expectedModel.isFavorite = false

        let clock = TestClock()
        var savedModels: [any MediaDTODescription] = []

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: model
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.continuousClock = clock

            $0.mediaDataWorker.updateOrDelete = { model in
                savedModels.append(model)
            }
        }

        await store.send(.likeTapped) {
            $0.model?.isFavorite = true
        }

        await store.send(.likeTapped) {
            $0.model?.isFavorite = false
        }

        await clock.advance(by: .milliseconds(300))

        await store.receive(.updateModel(expectedModel))

        XCTAssertEqual(savedModels.count, 1)
        XCTAssertEqual(savedModels.first?.isFavorite, false)
    }

    func test_bookmarkTapped_twiceQuickly_cancelsPreviousBookmarkEffectAndSavesOnlyLastState() async {
        let model = TvDTO.mock(
            id: "1",
            isBookmarked: false
        )

        var expectedModel: any MediaDTODescription = model
        expectedModel.isBookmarked = false

        let clock = TestClock()
        var savedModels: [any MediaDTODescription] = []

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: model
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.continuousClock = clock

            $0.mediaDataWorker.updateOrDelete = { model in
                savedModels.append(model)
            }
        }

        await store.send(.bookmarkTapped) {
            $0.model?.isBookmarked = true
        }

        await store.send(.bookmarkTapped) {
            $0.model?.isBookmarked = false
        }

        await clock.advance(by: .milliseconds(300))

        await store.receive(.updateModel(expectedModel))

        XCTAssertEqual(savedModels.count, 1)
        XCTAssertEqual(savedModels.first?.isBookmarked, false)
    }

    func test_updateModel_whenModelExists_setsModel() async {
        let initialModel = TvDTO.mock(
            id: "1",
            isFavorite: false,
            isBookmarked: false
        )

        let updatedModel = TvDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true
        )

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: initialModel
            )
        ) {
            DetailsFeature()
        }

        await store.send(.updateModel(updatedModel)) {
            $0.model = updatedModel
        }
    }

    func test_updateModel_whenModelNil_setsFlagsFalse() async {
        let initialModel = TvDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true
        )

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: initialModel
            )
        ) {
            DetailsFeature()
        }

        await store.send(.updateModel(nil)) {
            $0.model?.isFavorite = false
            $0.model?.isBookmarked = false
        }
    }

    func test_closeButtonTapped_dismissesScreen() async {
        var didDismiss = false

        let store = TestStore(
            initialState: DetailsFeature.State(
                model: TvDTO.mock(id: "1")
            )
        ) {
            DetailsFeature()
        } withDependencies: {
            $0.dismiss = DismissEffect {
                didDismiss = true
            }
        }

        await store.send(.closeButtonTapped)

        try? await Task.sleep(nanoseconds: 100_000_000)

        XCTAssertTrue(didDismiss)
    }
}

// MARK: - Equatable Helpers

extension DetailsFeature.State: @retroactive Equatable {

    public static func == (
        lhs: DetailsFeature.State,
        rhs: DetailsFeature.State
    ) -> Bool {
        lhs.model.isSameMedia(as: rhs.model)
        && lhs.destination.isSameDestination(as: rhs.destination)
    }
}

extension DetailsFeature.Action: @retroactive Equatable {

    public static func == (
        lhs: DetailsFeature.Action,
        rhs: DetailsFeature.Action
    ) -> Bool {
        switch (lhs, rhs) {
        case (.closeButtonTapped, .closeButtonTapped),
             (.likeTapped, .likeTapped),
             (.bookmarkTapped, .bookmarkTapped),
             (.onAppear, .onAppear),
             (.likeButtonTapped, .likeButtonTapped),
             (.bookmarkButtonTapped, .bookmarkButtonTapped):
            return true

        case let (.premiumChecked(lhsAction, lhsIsPremium),
                  .premiumChecked(rhsAction, rhsIsPremium)):
            return lhsAction == rhsAction
            && lhsIsPremium == rhsIsPremium

        case let (.updateModel(lhsModel), .updateModel(rhsModel)):
            return lhsModel.isSameMedia(as: rhsModel)

        case let (.itemTapped(lhsModel), .itemTapped(rhsModel)):
            return lhsModel.isSameMedia(as: rhsModel)

        case (.destination, .destination):
            return true

        default:
            return false
        }
    }
}

// MARK: - Media Compare

private extension MediaDTODescription {

    func isSameMedia(
        as other: any MediaDTODescription
    ) -> Bool {
        id == other.id
        && isFavorite == other.isFavorite
        && isBookmarked == other.isBookmarked
    }
}

private extension Optional where Wrapped == any MediaDTODescription {

    func isSameMedia(
        as other: (any MediaDTODescription)?
    ) -> Bool {
        switch (self, other) {
        case (.none, .none):
            return true

        case let (.some(lhs), .some(rhs)):
            return lhs.isSameMedia(as: rhs)

        default:
            return false
        }
    }
}

// MARK: - Destination Compare

private extension Optional where Wrapped == DetailsFeature.Destination.State {

    func isSameDestination(
        as other: DetailsFeature.Destination.State?
    ) -> Bool {
        switch (self, other) {
        case (.none, .none):
            return true

        case (.some(.paywall), .some(.paywall)):
            return true

        default:
            return false
        }
    }
}
