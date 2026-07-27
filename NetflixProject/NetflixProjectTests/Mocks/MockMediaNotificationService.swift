//
//  MockMediaNotificationService.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
@testable import NetflixProject
@testable import Storage

final class MockMediaNotificationService: MediaDataWorkerNotiServiceUseCaseProtocol {

    var madeNotificationsFromMovies: [MovieDTO] = []
    var removedNotificationIds: [String] = []
    var didRemoveAllNotifications = false

    var pendingIds: [String] = []
    var deliveredIds: [String] = []

    func makeNotifications(from dtos: [MovieDTO]) {
        madeNotificationsFromMovies.append(contentsOf: dtos)
    }

    func removeNotifications(ids: [String]) {
        removedNotificationIds.append(contentsOf: ids)
    }

    func removeAllNotifications() {
        didRemoveAllNotifications = true
    }

    func getPendingNotificationIds() async -> [String] {
        return pendingIds
    }

    func getDeliveredNotificationIds() async -> [String] {
        return deliveredIds
    }
}
