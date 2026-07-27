//
//  MovieDetailsVMTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 22.06.26.
//

import XCTest
import Combine
@testable import NetflixProject
@testable import Storage

final class MovieDetailsVMTests: XCTestCase {

    private var coordinator: MovieDetailsCoordinatorSpy!
    private var storage: MovieDetailsStorageStub!
    private var dataWorker: MovieDetailsMediaDataWorkerSpy!
    private var purchaseService: MovieDetailsPurchaseServiceStub!
    private var sut: MovieDetailsVM!

    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        coordinator = MovieDetailsCoordinatorSpy()
        storage = MovieDetailsStorageStub()
        dataWorker = MovieDetailsMediaDataWorkerSpy()
        purchaseService = MovieDetailsPurchaseServiceStub()
        bag = []
    }

    override func tearDown() {
        bag.removeAll()

        sut = nil
        coordinator = nil
        storage = nil
        dataWorker = nil
        purchaseService = nil
        bag = nil

        super.tearDown()
    }

    private func makeSut(
        model: MovieDTO = .mock()
    ) -> MovieDetailsVM {
        MovieDetailsVM(
            model: model,
            coordinator: coordinator,
            storage: storage,
            dataWorker: dataWorker,
            purchaseService: purchaseService
        )
    }
}

// MARK: - Init

extension MovieDetailsVMTests {

    func test_init_setsInitialMediaModel() {
        let model = MovieDTO.mock(id: "1")

        sut = makeSut(model: model)

        let modelExpectation = expectation(description: "Initial model received")

        sut.mediaModel
            .prefix(1)
            .sink { mediaModel in
                XCTAssertEqual(mediaModel?.id, "1")
                modelExpectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [modelExpectation], timeout: 1.0)

        bag.removeAll()
    }
}

// MARK: - On Appear

extension MovieDetailsVMTests {

    func test_onAppear_whenStorageReturnsModel_updatesMediaModelAndStates() {
        let initialModel = MovieDTO.mock(
            id: "1",
            isFavorite: false,
            isBookmarked: false,
            isSubscribed: false,
            releaseDate: "2999-01-01"
        )

        let storedModel = MovieDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true,
            isSubscribed: true,
            releaseDate: "2999-01-01"
        )

        storage.result = storedModel
        sut = makeSut(model: initialModel)

        let mediaExpectation = expectation(description: "Media model updated")
        let likeExpectation = expectation(description: "Like state updated")
        let bookmarkExpectation = expectation(description: "Bookmark state updated")
        let subscribeExpectation = expectation(description: "Subscribe state updated")
        let buttonExpectation = expectation(description: "Subscribe button state updated")

        sut.mediaModel
            .dropFirst()
            .prefix(1)
            .sink { model in
                XCTAssertEqual(model?.id, "1")
                XCTAssertEqual(model?.isFavorite, true)
                XCTAssertEqual(model?.isBookmarked, true)
                XCTAssertEqual(model?.isSubscribed, true)

                mediaExpectation.fulfill()
            }
            .store(in: &bag)

        sut.isLiked
            .dropFirst()
            .prefix(1)
            .sink { isLiked in
                XCTAssertTrue(isLiked)

                likeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.isBookmarked
            .dropFirst()
            .prefix(1)
            .sink { isBookmarked in
                XCTAssertTrue(isBookmarked)

                bookmarkExpectation.fulfill()
            }
            .store(in: &bag)

        sut.isSubscribed
            .dropFirst()
            .prefix(1)
            .sink { isSubscribed in
                XCTAssertTrue(isSubscribed)

                subscribeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.canShowSubscribeButton
            .dropFirst()
            .prefix(1)
            .sink { canShow in
                XCTAssertTrue(canShow)

                buttonExpectation.fulfill()
            }
            .store(in: &bag)

        sut.onAppear()

        wait(
            for: [
                mediaExpectation,
                likeExpectation,
                bookmarkExpectation,
                subscribeExpectation,
                buttonExpectation
            ],
            timeout: 1.0
        )

        bag.removeAll()

        XCTAssertTrue(storage.didFetch)
        XCTAssertEqual(storage.receivedId, "1")
    }

    func test_onAppear_whenStorageReturnsNil_updatesStatesWithFalse() {
        let initialModel = MovieDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true,
            isSubscribed: true,
            releaseDate: "2000-01-01"
        )

        storage.result = nil
        sut = makeSut(model: initialModel)

        let likeExpectation = expectation(description: "Like state updated")
        let bookmarkExpectation = expectation(description: "Bookmark state updated")
        let subscribeExpectation = expectation(description: "Subscribe state updated")
        let buttonExpectation = expectation(description: "Button state updated")

        sut.isLiked
            .dropFirst()
            .prefix(1)
            .sink { isLiked in
                XCTAssertFalse(isLiked)

                likeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.isBookmarked
            .dropFirst()
            .prefix(1)
            .sink { isBookmarked in
                XCTAssertFalse(isBookmarked)

                bookmarkExpectation.fulfill()
            }
            .store(in: &bag)

        sut.isSubscribed
            .dropFirst()
            .prefix(1)
            .sink { isSubscribed in
                XCTAssertFalse(isSubscribed)

                subscribeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.canShowSubscribeButton
            .dropFirst()
            .prefix(1)
            .sink { canShow in
                XCTAssertFalse(canShow)

                buttonExpectation.fulfill()
            }
            .store(in: &bag)

        sut.onAppear()

        wait(
            for: [
                likeExpectation,
                bookmarkExpectation,
                subscribeExpectation,
                buttonExpectation
            ],
            timeout: 1.0
        )

        bag.removeAll()

        XCTAssertTrue(storage.didFetch)
        XCTAssertEqual(storage.receivedId, "1")
    }

    func test_onAppear_withFutureReleaseDate_canShowSubscribeButtonTrue() {
        let model = MovieDTO.mock(
            id: "1",
            releaseDate: "2999-01-01"
        )

        storage.result = model
        sut = makeSut(model: model)

        let buttonExpectation = expectation(description: "Can show subscribe button")

        sut.canShowSubscribeButton
            .dropFirst()
            .prefix(1)
            .sink { canShow in
                XCTAssertTrue(canShow)

                buttonExpectation.fulfill()
            }
            .store(in: &bag)

        sut.onAppear()

        wait(for: [buttonExpectation], timeout: 1.0)

        bag.removeAll()
    }

    func test_onAppear_withPastReleaseDate_canShowSubscribeButtonFalse() {
        let model = MovieDTO.mock(
            id: "1",
            releaseDate: "2000-01-01"
        )

        storage.result = model
        sut = makeSut(model: model)

        let buttonExpectation = expectation(description: "Can show subscribe button false")

        sut.canShowSubscribeButton
            .dropFirst()
            .prefix(1)
            .sink { canShow in
                XCTAssertFalse(canShow)

                buttonExpectation.fulfill()
            }
            .store(in: &bag)

        sut.onAppear()

        wait(for: [buttonExpectation], timeout: 1.0)

        bag.removeAll()
    }

    func test_onAppear_withInvalidReleaseDate_canShowSubscribeButtonFalse() {
        let model = MovieDTO.mock(
            id: "1",
            releaseDate: "invalid-date"
        )

        storage.result = model
        sut = makeSut(model: model)

        let buttonExpectation = expectation(description: "Invalid release date handled")

        sut.canShowSubscribeButton
            .dropFirst()
            .prefix(1)
            .sink { canShow in
                XCTAssertFalse(canShow)

                buttonExpectation.fulfill()
            }
            .store(in: &bag)

        sut.onAppear()

        wait(for: [buttonExpectation], timeout: 1.0)

        bag.removeAll()
    }
}

// MARK: - Back

extension MovieDetailsVMTests {

    func test_backTapped_callsCoordinatorFinish() {
        sut = makeSut()

        sut.backTapped.send(())

        XCTAssertTrue(coordinator.didFinish)
        XCTAssertEqual(coordinator.finishCallCount, 1)
    }
}

// MARK: - Premium Active Actions

extension MovieDetailsVMTests {

    func test_likeTapped_whenPremiumActive_togglesLikeAndUpdatesDataWorker() {
        let model = MovieDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut(model: model)

        let likeExpectation = expectation(description: "Like updated")

        sut.isLiked
            .dropFirst()
            .prefix(1)
            .sink { isLiked in
                XCTAssertTrue(isLiked)

                likeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.likeTapped.send(())

        wait(for: [likeExpectation], timeout: 1.0)

        bag.removeAll()

        XCTAssertFalse(coordinator.didShowPaywall)

        let dataWorkerExpectation = expectation(description: "Data worker called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.receivedDTO?.id, "1")
            XCTAssertEqual(self.dataWorker.receivedDTO?.isFavorite, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }

    func test_bookmarkTapped_whenPremiumActive_togglesBookmarkAndUpdatesDataWorker() {
        let model = MovieDTO.mock(
            id: "1",
            isBookmarked: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut(model: model)

        let bookmarkExpectation = expectation(description: "Bookmark updated")

        sut.isBookmarked
            .dropFirst()
            .prefix(1)
            .sink { isBookmarked in
                XCTAssertTrue(isBookmarked)

                bookmarkExpectation.fulfill()
            }
            .store(in: &bag)

        sut.bookmarkTapped.send(())

        wait(for: [bookmarkExpectation], timeout: 1.0)

        bag.removeAll()

        XCTAssertFalse(coordinator.didShowPaywall)

        let dataWorkerExpectation = expectation(description: "Data worker called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.receivedDTO?.id, "1")
            XCTAssertEqual(self.dataWorker.receivedDTO?.isBookmarked, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }

    func test_subscribeTapped_whenPremiumActive_togglesSubscribeAndUpdatesDataWorker() {
        let model = MovieDTO.mock(
            id: "1",
            isSubscribed: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut(model: model)

        let subscribeExpectation = expectation(description: "Subscribe updated")

        sut.isSubscribed
            .dropFirst()
            .prefix(1)
            .sink { isSubscribed in
                XCTAssertTrue(isSubscribed)

                subscribeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.subscribeTapped.send(())

        wait(for: [subscribeExpectation], timeout: 1.0)

        bag.removeAll()

        XCTAssertFalse(coordinator.didShowPaywall)

        let dataWorkerExpectation = expectation(description: "Data worker called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.receivedDTO?.id, "1")
            XCTAssertEqual(self.dataWorker.receivedDTO?.isSubscribed, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }
}

// MARK: - Premium Inactive Actions

extension MovieDetailsVMTests {

    func test_likeTapped_whenPremiumInactive_showsPaywallAndDoesNotToggleLike() {
        let model = MovieDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResult = false
        sut = makeSut(model: model)

        sut.likeTapped.send(())

        let paywallExpectation = expectation(description: "Paywall shown")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.coordinator.didShowPaywall)
            XCTAssertEqual(self.coordinator.showPaywallCallCount, 1)
            XCTAssertFalse(self.dataWorker.didUpdateOrDelete)

            paywallExpectation.fulfill()
        }

        wait(for: [paywallExpectation], timeout: 1.0)
    }

    func test_bookmarkTapped_whenPremiumInactive_showsPaywallAndDoesNotToggleBookmark() {
        let model = MovieDTO.mock(
            id: "1",
            isBookmarked: false
        )

        purchaseService.hasActiveSubscriptionResult = false
        sut = makeSut(model: model)

        sut.bookmarkTapped.send(())

        let paywallExpectation = expectation(description: "Paywall shown")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.coordinator.didShowPaywall)
            XCTAssertEqual(self.coordinator.showPaywallCallCount, 1)
            XCTAssertFalse(self.dataWorker.didUpdateOrDelete)

            paywallExpectation.fulfill()
        }

        wait(for: [paywallExpectation], timeout: 1.0)
    }

    func test_subscribeTapped_whenPremiumInactive_showsPaywallAndDoesNotToggleSubscribe() {
        let model = MovieDTO.mock(
            id: "1",
            isSubscribed: false
        )

        purchaseService.hasActiveSubscriptionResult = false
        sut = makeSut(model: model)

        sut.subscribeTapped.send(())

        let paywallExpectation = expectation(description: "Paywall shown")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.coordinator.didShowPaywall)
            XCTAssertEqual(self.coordinator.showPaywallCallCount, 1)
            XCTAssertFalse(self.dataWorker.didUpdateOrDelete)

            paywallExpectation.fulfill()
        }

        wait(for: [paywallExpectation], timeout: 1.0)
    }
}

// MARK: - Continue Pending Premium Action

extension MovieDetailsVMTests {

    func test_continuePendingPremiumActionIfNeeded_afterPaywallDismissAndPremiumActive_performsPendingLike() {
        let model = MovieDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResults = [false, true]
        sut = makeSut(model: model)

        let likeExpectation = expectation(description: "Pending like performed")

        sut.isLiked
            .dropFirst()
            .prefix(1)
            .sink { isLiked in
                XCTAssertTrue(isLiked)

                likeExpectation.fulfill()
            }
            .store(in: &bag)

        sut.likeTapped.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.coordinator.didShowPaywall)
            XCTAssertEqual(self.coordinator.showPaywallCallCount, 1)

            self.coordinator.onPaywallDismiss?()
        }

        wait(for: [likeExpectation], timeout: 1.0)

        bag.removeAll()

        let dataWorkerExpectation = expectation(description: "Data worker called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.receivedDTO?.isFavorite, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }

    func test_continuePendingPremiumActionIfNeeded_afterPaywallDismissAndPremiumStillInactive_doesNotPerformAction() {
        let model = MovieDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResults = [false, false]
        sut = makeSut(model: model)

        sut.likeTapped.send(())

        let actionExpectation = expectation(description: "Pending action not performed")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.coordinator.didShowPaywall)
            XCTAssertEqual(self.coordinator.showPaywallCallCount, 1)

            self.coordinator.onPaywallDismiss?()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                XCTAssertFalse(self.dataWorker.didUpdateOrDelete)

                actionExpectation.fulfill()
            }
        }

        wait(for: [actionExpectation], timeout: 1.0)
    }

    func test_continuePendingPremiumActionIfNeeded_withoutPendingAction_doesNothing() {
        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut()

        sut.continuePendingPremiumActionIfNeeded()

        let actionExpectation = expectation(description: "No pending action")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertFalse(self.dataWorker.didUpdateOrDelete)
            XCTAssertFalse(self.coordinator.didShowPaywall)

            actionExpectation.fulfill()
        }

        wait(for: [actionExpectation], timeout: 1.0)
    }
}

// MARK: - Update Task

extension MovieDetailsVMTests {

    func test_likeTapped_twiceQuickly_cancelsPreviousUpdateTaskAndSavesOnlyLastState() {
        let model = MovieDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut(model: model)

        sut.likeTapped.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.sut.likeTapped.send(())
        }

        let saveExpectation = expectation(description: "Only last update saved")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)
            XCTAssertEqual(self.dataWorker.receivedDTO?.isFavorite, false)

            saveExpectation.fulfill()
        }

        wait(for: [saveExpectation], timeout: 1.2)
    }

    func test_updateModel_whenDataWorkerThrows_doesNotCrash() {
        let model = MovieDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        dataWorker.error = NSError(domain: "Test", code: 1)
        sut = makeSut(model: model)

        sut.likeTapped.send(())

        let errorExpectation = expectation(description: "Error handled")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)

            errorExpectation.fulfill()
        }

        wait(for: [errorExpectation], timeout: 1.0)
    }
}
