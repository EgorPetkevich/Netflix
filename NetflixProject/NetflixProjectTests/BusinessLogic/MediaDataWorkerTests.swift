//
//  MediaDataWorkerTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
import XCTest
@testable import NetflixProject
@testable import Storage

final class MediaDataWorkerTests: XCTestCase {

    private var backup: MockMediaBackup!
    private var storage: MockMediaStorage!
    private var notiService: MockMediaNotificationService!
    private var sut: MediaDataWorker!

    override func setUp() {
        super.setUp()
        backup = MockMediaBackup()
        storage = MockMediaStorage()
        notiService = MockMediaNotificationService()

        sut = MediaDataWorker(
            backup: backup,
            storage: storage,
            notiService: notiService
        )
    }

    override func tearDown() {
        sut = nil
        backup = nil
        storage = nil
        notiService = nil
        super.tearDown()
    }

    func test_updateOrCreate_subscribedMovie_makesNotification() async throws {
        let movie = MovieDTO.mock(
            id: "1",
            isSubscribed: true
        )

        try await sut.updateOrCreate(dto: movie)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(backup.sentDTOs.count, 1)
        XCTAssertEqual(notiService.madeNotificationsFromMovies.map { $0.id }, ["1"])
        XCTAssertTrue(notiService.removedNotificationIds.isEmpty)
    }

    func test_updateOrCreate_unsubscribedMovie_removesNotification() async throws {
        let movie = MovieDTO.mock(
            id: "1",
            isSubscribed: false
        )

        try await sut.updateOrCreate(dto: movie)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(backup.sentDTOs.count, 1)
        XCTAssertTrue(notiService.madeNotificationsFromMovies.isEmpty)
        XCTAssertEqual(notiService.removedNotificationIds, ["1"])
    }

    func test_updateOrDelete_movieWithAllFlagsFalse_deletesMovie() async throws {
        let movie = MovieDTO.mock(
            id: "1",
            isFavorite: false,
            isBookmarked: false,
            isSubscribed: false
        )

        try await sut.updateOrDelete(dto: movie)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(storage.deletedDTOs.count, 1)
        XCTAssertEqual(backup.deletedDTOs.count, 1)
        XCTAssertEqual(notiService.removedNotificationIds, ["1"])
    }

    func test_updateOrDelete_favoriteMovie_updatesMovie() async throws {
        let movie = MovieDTO.mock(
            id: "1",
            isFavorite: true,
            isBookmarked: false,
            isSubscribed: false
        )

        try await sut.updateOrDelete(dto: movie)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(backup.sentDTOs.count, 1)
        XCTAssertEqual(storage.deletedDTOs.count, 0)
        XCTAssertEqual(backup.deletedDTOs.count, 0)
        XCTAssertEqual(notiService.removedNotificationIds, ["1"])
    }

    func test_updateOrDelete_bookmarkedMovie_updatesMovie() async throws {
        let movie = MovieDTO.mock(
            id: "1",
            isFavorite: false,
            isBookmarked: true,
            isSubscribed: false
        )

        try await sut.updateOrDelete(dto: movie)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(backup.sentDTOs.count, 1)
        XCTAssertEqual(storage.deletedDTOs.count, 0)
        XCTAssertEqual(backup.deletedDTOs.count, 0)
        XCTAssertEqual(notiService.removedNotificationIds, ["1"])
    }

    func test_updateOrDelete_regularDTOWithAllFlagsFalse_deletesDTO() async throws {
        let dto = MockMediaDTO.make(
            id: "1",
            isFavorite: false,
            isBookmarked: false
        )

        try await sut.updateOrDelete(dto: dto)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(storage.deletedDTOs.count, 1)
        XCTAssertEqual(backup.deletedDTOs.count, 1)

        XCTAssertTrue(notiService.madeNotificationsFromMovies.isEmpty)
        XCTAssertTrue(notiService.removedNotificationIds.isEmpty)
    }

    func test_updateOrDelete_regularFavoriteDTO_updatesDTO() async throws {
        let dto = MockMediaDTO.make(
            id: "1",
            isFavorite: true,
            isBookmarked: false
        )

        try await sut.updateOrDelete(dto: dto)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(backup.sentDTOs.count, 1)
        XCTAssertEqual(storage.deletedDTOs.count, 0)
        XCTAssertEqual(backup.deletedDTOs.count, 0)
    }

    func test_updateOrDelete_regularBookmarkedDTO_updatesDTO() async throws {
        let dto = MockMediaDTO.make(
            id: "1",
            isFavorite: false,
            isBookmarked: true
        )

        try await sut.updateOrDelete(dto: dto)

        XCTAssertEqual(storage.updatedDTOs.count, 1)
        XCTAssertEqual(backup.sentDTOs.count, 1)
        XCTAssertEqual(storage.deletedDTOs.count, 0)
    }

    func test_waitingsCount_returnsPendingNotificationsCount() async {
        notiService.pendingIds = ["1", "2", "3"]

        let result = await sut.waitingsCount()

        XCTAssertEqual(result, 3)
    }

    func test_getDelivered_fetchesMoviesByDeliveredNotificationIds() async {
        notiService.deliveredIds = ["100", "200"]

        let movie1 = MovieDTO.mock(id: "100")
        let movie2 = MovieDTO.mock(id: "200")
        storage.moviesToReturn = [movie1, movie2]

        let result = await sut.getDelivered()

        XCTAssertEqual(storage.fetchMoviesIds, ["100", "200"])
        XCTAssertEqual(result.map { $0.id }, ["100", "200"])
    }

    func test_getWaitings_fetchesMoviesByPendingNotificationIds() async {
        notiService.pendingIds = ["10", "20"]

        let movie1 = MovieDTO.mock(id: "10")
        let movie2 = MovieDTO.mock(id: "20")
        storage.moviesToReturn = [movie1, movie2]

        let result = await sut.getWaitings()

        XCTAssertEqual(storage.fetchMoviesIds, ["10", "20"])
        XCTAssertEqual(result.map { $0.id }, ["10", "20"])
    }

    func test_delete_movie_deletesFromStorageBackupAndNotifications() async throws {
        let movie = MovieDTO.mock(id: "123")

        try await sut.delete(dto: movie)

        XCTAssertEqual(storage.deletedDTOs.count, 1)
        XCTAssertEqual(backup.deletedDTOs.count, 1)
        XCTAssertEqual(notiService.removedNotificationIds, ["123"])
    }

    func test_delete_regularDTO_doesNotTouchNotifications() async throws {
        let dto = MockMediaDTO.make(id: "regular")

        try await sut.delete(dto: dto)

        XCTAssertEqual(storage.deletedDTOs.count, 1)
        XCTAssertEqual(backup.deletedDTOs.count, 1)
        XCTAssertTrue(notiService.removedNotificationIds.isEmpty)
        XCTAssertTrue(notiService.madeNotificationsFromMovies.isEmpty)
    }

    func test_restore_updatesStorageAndRestoresOnlySubscribedMovieNotifications() async {
        let subscribedMovie = MovieDTO.mock(id: "subscribed", isSubscribed: true)
        let unsubscribedMovie = MovieDTO.mock(id: "unsubscribed", isSubscribed: false)
        let dto = MockMediaDTO.make(id: "regular")
        backup.dtosToLoad = [subscribedMovie, unsubscribedMovie, dto]

        await sut.restore()

        XCTAssertEqual(storage.updatedDTOs.count, 3)
        XCTAssertEqual(
            storage.updatedDTOs.map(\.id),
            ["subscribed", "unsubscribed", "regular"]
        )
        XCTAssertEqual(
            notiService.madeNotificationsFromMovies.map(\.id),
            ["subscribed"]
        )
    }
}
