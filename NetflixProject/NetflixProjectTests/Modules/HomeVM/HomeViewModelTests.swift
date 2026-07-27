//
//  HomeViewModelTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 18.06.26.
//

import XCTest
import Combine
@testable import NetflixProject
@testable import Storage

final class HomeVMTests: XCTestCase {

    private var coordinator: HomeCoordinatorSpy!
    private var contentLoader: HomeContentLoaderStub!
    private var alertService: HomeAlertServiceSpy!
    private var sut: HomeVM!

    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        coordinator = HomeCoordinatorSpy()
        contentLoader = HomeContentLoaderStub()
        alertService = HomeAlertServiceSpy()
        bag = []
    }

    override func tearDown() {
        sut = nil
        coordinator = nil
        contentLoader = nil
        alertService = nil
        bag = nil
        super.tearDown()
    }

    private func makeSut() -> HomeVM {
        HomeVM(
            coordinator: coordinator,
            contentLoader: contentLoader,
            alertService: alertService
        )
    }

    private func makeSection(
        type: MediaSectionType = .tv(.airing),
        media: [any MediaDTODescription] = [MockMediaDTO.make()],
        page: Int = 1,
        isLoading: Bool = false
    ) -> MediaListSection {
        MediaListSection(
            type: type,
            media: media,
            page: page,
            isLoading: isLoading
        )
    }
}

// MARK: - Init / Load Home Content

extension HomeVMTests {

    func test_init_loadsHomeContentAndUpdatesSections() {
        let section = makeSection(type: .tv(.airing))

        contentLoader.homeContentResult = .success([section])
        sut = makeSut()

        let expectation = expectation(description: "Sections updated")

        sut.sections
            .dropFirst()
            .sink { sections in
                XCTAssertEqual(sections.count, 1)
                XCTAssertEqual(sections.first?.type, .tv(.airing))

                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Show All

extension HomeVMTests {

    func test_showAllTapped_callsCoordinatorShowCatalog() {
        let section = makeSection(type: .tv(.airing))

        contentLoader.homeContentResult = .success([section])
        sut = makeSut()

        let expectation = expectation(description: "Catalog shown")

        sut.sections
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }

                self.sut.showAllTapped.send(.tv(.airing))

                XCTAssertTrue(self.coordinator.didShowCatalog)
                XCTAssertEqual(self.coordinator.receivedSection?.type, .tv(.airing))

                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Load Next Page

extension HomeVMTests {

    func test_loadNextItems_loadsNextPageAndAppendsMedia() {
        let firstMedia = MockMediaDTO.make(id: "1")
        let nextMedia = MockMediaDTO.make(id: "2")

        let initialSection = makeSection(
            type: .tv(.airing),
            media: [firstMedia],
            page: 1,
            isLoading: false
        )

        contentLoader.homeContentResult = .success([initialSection])
        contentLoader.nextPageResult = .success([nextMedia])

        sut = makeSut()

        let expectation = expectation(description: "Next page loaded")
        var didSendLoadNext = false

        sut.sections
            .dropFirst()
            .sink { [weak self] sections in
                guard let self else { return }

                guard let section = sections.first(where: { $0.type == .tv(.airing) }) else {
                    return
                }

                if section.page == 1, didSendLoadNext == false {
                    didSendLoadNext = true
                    self.sut.loadNextItems.send(.tv(.airing))
                    return
                }

                if section.page == 2 {
                    XCTAssertEqual(section.type, .tv(.airing))
                    XCTAssertEqual(section.page, 2)
                    XCTAssertEqual(section.media.count, 2)
                    XCTAssertEqual(section.media.first?.id, "1")
                    XCTAssertEqual(section.media.last?.id, "2")

                    expectation.fulfill()
                }
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_loadNextPage_whenSectionWithTypeDoesNotExist_doesNotLoadNextPage() {
        let section = makeSection(
            type: .tv(.airing),
            media: [MockMediaDTO.make(id: "1")],
            page: 1,
            isLoading: false
        )

        contentLoader.homeContentResult = .success([section])
        sut = makeSut()

        let expectation = expectation(description: "Initial sections loaded")

        sut.sections
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }

                self.sut.loadNextPage(for: .movie(.popular))

                XCTAssertFalse(self.contentLoader.didLoadNextPage)
                XCTAssertNil(self.contentLoader.receivedNextPageType)
                XCTAssertNil(self.contentLoader.receivedNextPage)

                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_loadNextPage_whenPageLimitReached_doesNotLoadNextPage() {
        let section = makeSection(
            type: .tv(.airing),
            media: [MockMediaDTO.make(id: "1")],
            page: 2,
            isLoading: false
        )

        contentLoader.homeContentResult = .success([section])
        sut = makeSut()

        let expectation = expectation(description: "Initial sections loaded")

        sut.sections
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }

                self.sut.loadNextPage(for: .tv(.airing))

                XCTAssertFalse(self.contentLoader.didLoadNextPage)
                XCTAssertNil(self.contentLoader.receivedNextPageType)
                XCTAssertNil(self.contentLoader.receivedNextPage)

                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_loadNextPage_whenSectionIsAlreadyLoading_doesNotLoadNextPage() {
        let section = makeSection(
            type: .tv(.airing),
            media: [MockMediaDTO.make(id: "1")],
            page: 1,
            isLoading: true
        )

        contentLoader.homeContentResult = .success([section])
        sut = makeSut()

        let expectation = expectation(description: "Initial sections loaded")

        sut.sections
            .dropFirst()
            .sink { [weak self] _ in
                guard let self else { return }

                self.sut.loadNextPage(for: .tv(.airing))

                XCTAssertFalse(self.contentLoader.didLoadNextPage)
                XCTAssertNil(self.contentLoader.receivedNextPageType)
                XCTAssertNil(self.contentLoader.receivedNextPage)

                expectation.fulfill()
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }

    func test_loadNextPage_whenContentLoaderFails_showsFetchErrorAlert() {
        let section = makeSection(
            type: .tv(.airing),
            media: [MockMediaDTO.make(id: "1")],
            page: 1,
            isLoading: false
        )

        contentLoader.homeContentResult = .success([section])
        contentLoader.nextPageResult = .failure(NSError(domain: "Test", code: 1))

        sut = makeSut()

        let expectation = expectation(description: "Alert shown after next page failure")
        var didTriggerLoadNext = false

        sut.sections
            .dropFirst()
            .sink { [weak self] sections in
                guard let self else { return }

                let currentSection = sections.first(where: { $0.type == .tv(.airing) })

                if currentSection?.page == 1, didTriggerLoadNext == false {
                    didTriggerLoadNext = true
                    self.sut.loadNextPage(for: .tv(.airing))
                    return
                }

                if self.alertService.didShowAlert {
                    XCTAssertTrue(self.contentLoader.didLoadNextPage)
                    XCTAssertEqual(self.contentLoader.receivedNextPageType, .tv(.airing))
                    XCTAssertEqual(self.contentLoader.receivedNextPage, 2)
                    XCTAssertTrue(self.alertService.didShowAlert)

                    expectation.fulfill()
                }
            }
            .store(in: &bag)

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Did Select Item

extension HomeVMTests {

    func test_didSelectItem_withMovieDTO_callsCoordinatorShowMovieDetails() {
        let model = MovieDTO.mock()

        sut = makeSut()

        sut.didSelectItem.send(model)

        XCTAssertTrue(coordinator.didShowMovieDetails)
        XCTAssertTrue(coordinator.didShowDetails)
        XCTAssertEqual(coordinator.receivedMovieDTO?.id, "1")
        XCTAssertFalse(coordinator.didShowTvDetails)
    }

    func test_didSelectItem_withTvDTO_callsCoordinatorShowTvDetails() {
        let model = TvDTO.mock()

        sut = makeSut()

        sut.didSelectItem.send(model)

        XCTAssertTrue(coordinator.didShowTvDetails)
        XCTAssertTrue(coordinator.didShowDetails)
        XCTAssertEqual(coordinator.receivedTvDTO?.id, "1")
        XCTAssertFalse(coordinator.didShowMovieDetails)
    }

    func test_didSelectItem_withUnknownMediaDTO_doesNotShowDetails() {
        let model = MockMediaDTO.make(id: "1")

        sut = makeSut()

        sut.didSelectItem.send(model)

        XCTAssertFalse(coordinator.didShowDetails)
        XCTAssertFalse(coordinator.didShowMovieDetails)
        XCTAssertFalse(coordinator.didShowTvDetails)
        XCTAssertNil(coordinator.receivedMovieDTO)
        XCTAssertNil(coordinator.receivedTvDTO)
    }
}

// MARK: - Header Details Tapped

extension HomeVMTests {

    func test_headerDetailsTapped_withMovieDTO_callsCoordinatorShowMovieDetails() {
        let model = MovieDTO.mock()

        sut = makeSut()

        sut.headerDetailsTapped.send(model)

        XCTAssertTrue(coordinator.didShowMovieDetails)
        XCTAssertTrue(coordinator.didShowDetails)
        XCTAssertEqual(coordinator.receivedMovieDTO?.id, "1")
        XCTAssertFalse(coordinator.didShowTvDetails)
    }

    func test_headerDetailsTapped_withTvDTO_callsCoordinatorShowTvDetails() {
        let model = TvDTO.mock()

        sut = makeSut()

        sut.headerDetailsTapped.send(model)

        XCTAssertTrue(coordinator.didShowTvDetails)
        XCTAssertTrue(coordinator.didShowDetails)
        XCTAssertEqual(coordinator.receivedTvDTO?.id, "1")
        XCTAssertFalse(coordinator.didShowMovieDetails)
    }

    func test_headerDetailsTapped_withUnknownMediaDTO_doesNotShowDetails() {
        let model = MockMediaDTO.make(id: "1")

        sut = makeSut()

        sut.headerDetailsTapped.send(model)

        XCTAssertFalse(coordinator.didShowDetails)
        XCTAssertFalse(coordinator.didShowMovieDetails)
        XCTAssertFalse(coordinator.didShowTvDetails)
        XCTAssertNil(coordinator.receivedMovieDTO)
        XCTAssertNil(coordinator.receivedTvDTO)
    }
}

// MARK: - Content Loading State

extension HomeVMTests {

    func test_contentLoadingStateIdleLoadingReady_doesNotShowAlert() {
        contentLoader.homeContentResult = .success([])
        sut = makeSut()

        let expectation = expectation(description: "States handled")

        DispatchQueue.main.async {
            self.contentLoader.stateSubject.send(.idle)
            self.contentLoader.stateSubject.send(.loading)
            self.contentLoader.stateSubject.send(.ready)

            DispatchQueue.main.async {
                XCTAssertFalse(self.alertService.didShowAlert)
                XCTAssertEqual(self.alertService.showAlertCallCount, 0)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_contentLoadingStateFailed_showsFetchErrorAlert() {
        contentLoader.homeContentResult = .success([])
        sut = makeSut()

        let expectation = expectation(description: "Alert shown")

        DispatchQueue.main.async {
            self.contentLoader.stateSubject.send(.failed(""))

            DispatchQueue.main.async {
                XCTAssertTrue(self.alertService.didShowAlert)
                XCTAssertEqual(
                    self.alertService.receivedTitle,
                    L10n.mainHomeAlertConnectionTitleError
                )
                XCTAssertEqual(
                    self.alertService.receivedMessage,
                    L10n.mainHomeAlertConnectionSubtitleError
                )

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

// MARK: - Fetch Error Alert

extension HomeVMTests {

    func test_showFetchErrorAlert_whenAlertAlreadyShowing_doesNotShowSecondAlert() {
        contentLoader.homeContentResult = .success([])
        sut = makeSut()

        let expectation = expectation(description: "Only one alert shown")

        DispatchQueue.main.async {
            self.contentLoader.stateSubject.send(.failed(""))
            self.contentLoader.stateSubject.send(.failed(""))

            DispatchQueue.main.async {
                XCTAssertTrue(self.alertService.didShowAlert)
                XCTAssertEqual(self.alertService.showAlertCallCount, 1)

                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchErrorAlertCancelHandler_allowsShowingAlertAgain() {
        contentLoader.homeContentResult = .success([])
        sut = makeSut()

        let expectation = expectation(description: "Cancel handler resets alert flag")

        DispatchQueue.main.async {
            self.contentLoader.stateSubject.send(.failed(""))

            DispatchQueue.main.async {
                XCTAssertEqual(self.alertService.showAlertCallCount, 1)

                self.alertService.cancelHandler?()
                self.contentLoader.stateSubject.send(.failed(""))

                DispatchQueue.main.async {
                    XCTAssertEqual(self.alertService.showAlertCallCount, 2)

                    expectation.fulfill()
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_fetchErrorAlertOkHandler_retriesLoadHomeContent() {
        contentLoader.homeContentResult = .success([])
        sut = makeSut()

        let expectation = expectation(description: "Ok handler retries loading")

        DispatchQueue.main.async {
            self.contentLoader.stateSubject.send(.failed(""))

            DispatchQueue.main.async {
                XCTAssertEqual(self.alertService.showAlertCallCount, 1)
                XCTAssertEqual(self.contentLoader.loadHomeContentCallCount, 1)

                self.alertService.okHandler?()

                DispatchQueue.main.async {
                    XCTAssertEqual(self.contentLoader.loadHomeContentCallCount, 2)

                    self.contentLoader.stateSubject.send(.failed(""))

                    DispatchQueue.main.async {
                        XCTAssertEqual(self.alertService.showAlertCallCount, 2)

                        expectation.fulfill()
                    }
                }
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}
