//
//  TvDetailsVMTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 23.06.26.
//

import XCTest
import Combine
@testable import NetflixProject
@testable import Storage

final class TvDetailsVMTests: XCTestCase {

    private var coordinator: TvDetailsCoordinatorSpy!
    private var storage: TvDetailsStorageStub!
    private var dataWorker: TvDetailsMediaDataWorkerSpy!
    private var purchaseService: TvDetailsPurchaseServiceStub!
    private var sut: TvDetailsVM!

    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()

        coordinator = TvDetailsCoordinatorSpy()
        storage = TvDetailsStorageStub()
        dataWorker = TvDetailsMediaDataWorkerSpy()
        purchaseService = TvDetailsPurchaseServiceStub()
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
        model: any MediaDTODescription = TvDTO.mock()
    ) -> TvDetailsVM {
        TvDetailsVM(
            model: model,
            coordinator: coordinator,
            storage: storage,
            dataWorker: dataWorker,
            purchaseService: purchaseService
        )
    }
}

// MARK: - Init

extension TvDetailsVMTests {

    func test_init_setsInitialMediaModel() {
        let model = TvDTO.mock(id: "1")

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

extension TvDetailsVMTests {

    func test_onAppear_whenStorageReturnsModel_updatesMediaModelAndStates() {
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

        storage.result = storedModel
        sut = makeSut(model: initialModel)

        let mediaExpectation = expectation(description: "Media model updated")
        let likeExpectation = expectation(description: "Like state updated")
        let bookmarkExpectation = expectation(description: "Bookmark state updated")

        sut.mediaModel
            .dropFirst()
            .prefix(1)
            .sink { mediaModel in
                XCTAssertEqual(mediaModel?.id, "1")
                XCTAssertEqual(mediaModel?.isFavorite, true)
                XCTAssertEqual(mediaModel?.isBookmarked, true)

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

        sut.onAppear()

        wait(
            for: [
                mediaExpectation,
                likeExpectation,
                bookmarkExpectation
            ],
            timeout: 1.0
        )

        bag.removeAll()

        XCTAssertTrue(storage.didFetch)
        XCTAssertEqual(storage.receivedId, "1")
    }

    func test_onAppear_whenStorageReturnsNil_updatesStatesWithFalse() {
        let initialModel = TvDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: true
        )

        storage.result = nil
        sut = makeSut(model: initialModel)

        let likeExpectation = expectation(description: "Like state updated")
        let bookmarkExpectation = expectation(description: "Bookmark state updated")

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

        sut.onAppear()

        wait(
            for: [
                likeExpectation,
                bookmarkExpectation
            ],
            timeout: 1.0
        )

        bag.removeAll()

        XCTAssertTrue(storage.didFetch)
        XCTAssertEqual(storage.receivedId, "1")
    }
}

// MARK: - Back

extension TvDetailsVMTests {

    func test_backTapped_callsCoordinatorFinish() {
        sut = makeSut()

        sut.backTapped.send(())

        XCTAssertTrue(coordinator.didFinish)
        XCTAssertEqual(coordinator.finishCallCount, 1)
    }
}

// MARK: - Premium Active Actions

extension TvDetailsVMTests {

    func test_likeTapped_whenPremiumActive_togglesLikeAndUpdatesDataWorker() {
        let model = TvDTO.mock(
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
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)
            XCTAssertEqual(self.dataWorker.receivedDTO?.id, "1")
            XCTAssertEqual(self.dataWorker.receivedDTO?.isFavorite, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }

    func test_bookmarkTapped_whenPremiumActive_togglesBookmarkAndUpdatesDataWorker() {
        let model = TvDTO.mock(
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
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)
            XCTAssertEqual(self.dataWorker.receivedDTO?.id, "1")
            XCTAssertEqual(self.dataWorker.receivedDTO?.isBookmarked, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }
}

// MARK: - Premium Inactive Actions

extension TvDetailsVMTests {

    func test_likeTapped_whenPremiumInactive_showsPaywallAndDoesNotToggleLike() {
        let model = TvDTO.mock(
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
        let model = TvDTO.mock(
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
}

// MARK: - Continue Pending Premium Action

extension TvDetailsVMTests {

    func test_continuePendingPremiumActionIfNeeded_afterPaywallDismissAndPremiumActive_performsPendingLike() {
        let model = TvDTO.mock(
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

    func test_continuePendingPremiumActionIfNeeded_afterPaywallDismissAndPremiumActive_performsPendingBookmark() {
        let model = TvDTO.mock(
            id: "1",
            isBookmarked: false
        )

        purchaseService.hasActiveSubscriptionResults = [false, true]
        sut = makeSut(model: model)

        let bookmarkExpectation = expectation(description: "Pending bookmark performed")

        sut.isBookmarked
            .dropFirst()
            .prefix(1)
            .sink { isBookmarked in
                XCTAssertTrue(isBookmarked)

                bookmarkExpectation.fulfill()
            }
            .store(in: &bag)

        sut.bookmarkTapped.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(self.coordinator.didShowPaywall)
            XCTAssertEqual(self.coordinator.showPaywallCallCount, 1)

            self.coordinator.onPaywallDismiss?()
        }

        wait(for: [bookmarkExpectation], timeout: 1.0)

        bag.removeAll()

        let dataWorkerExpectation = expectation(description: "Data worker called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.receivedDTO?.isBookmarked, true)

            dataWorkerExpectation.fulfill()
        }

        wait(for: [dataWorkerExpectation], timeout: 1.0)
    }

    func test_continuePendingPremiumActionIfNeeded_afterPaywallDismissAndPremiumStillInactive_doesNotPerformAction() {
        let model = TvDTO.mock(
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

// MARK: - Task Cancellation

extension TvDetailsVMTests {

    func test_likeTapped_twiceQuickly_cancelsPreviousLikeTaskAndSavesOnlyLastState() {
        let model = TvDTO.mock(
            id: "1",
            isFavorite: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut(model: model)

        sut.likeTapped.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.sut.likeTapped.send(())
        }

        let saveExpectation = expectation(description: "Only last like update saved")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)
            XCTAssertEqual(self.dataWorker.receivedDTO?.isFavorite, false)

            saveExpectation.fulfill()
        }

        wait(for: [saveExpectation], timeout: 1.2)
    }

    func test_bookmarkTapped_twiceQuickly_cancelsPreviousBookmarkTaskAndSavesOnlyLastState() {
        let model = TvDTO.mock(
            id: "1",
            isBookmarked: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        sut = makeSut(model: model)

        sut.bookmarkTapped.send(())

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.sut.bookmarkTapped.send(())
        }

        let saveExpectation = expectation(description: "Only last bookmark update saved")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)
            XCTAssertEqual(self.dataWorker.receivedDTO?.isBookmarked, false)

            saveExpectation.fulfill()
        }

        wait(for: [saveExpectation], timeout: 1.2)
    }

    func test_likeTapped_whenDataWorkerThrows_doesNotCrash() {
        let model = TvDTO.mock(
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

    func test_bookmarkTapped_whenDataWorkerThrows_doesNotCrash() {
        let model = TvDTO.mock(
            id: "1",
            isBookmarked: false
        )

        purchaseService.hasActiveSubscriptionResult = true
        dataWorker.error = NSError(domain: "Test", code: 1)
        sut = makeSut(model: model)

        sut.bookmarkTapped.send(())

        let errorExpectation = expectation(description: "Error handled")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            XCTAssertTrue(self.dataWorker.didUpdateOrDelete)
            XCTAssertEqual(self.dataWorker.updateOrDeleteCallCount, 1)

            errorExpectation.fulfill()
        }

        wait(for: [errorExpectation], timeout: 1.0)
    }
}
