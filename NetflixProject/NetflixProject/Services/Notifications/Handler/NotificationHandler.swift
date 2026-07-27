//
//  NotificationHandler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import Foundation
import UserNotifications
import Storage

final class NotificationHandler {

    private let storage: MovieStorage = .init()
    private let notificationCenter = UNUserNotificationCenter.current()

    func chekIsCompleted() async throws {
        async let notification = notificationCenter.deliveredNotifications()

        try await self.setIsCompleted(notifications: notification)
    }

    func setIsComplited(notification: UNNotification) async throws {
        let id = notification.request.identifier
        let date = notification.date

        var dto = await storage.fetch(by: id)

        dto?.releaseDate = "\(date)"

        guard let dto else { return }
        try await storage.updateOrCreate(dto: dto)

    }

    private func setIsCompleted(notifications: [UNNotification]) async throws {
        let ids = notifications.map { $0.request.identifier }

        let dtos = await storage
            .fetch(by: ids)
            .map { dto in
                var updatedDTO = dto
                let date = notifications.first { $0.request.identifier == dto.id }?.date
                if let date {
                    updatedDTO.releaseDate = "\(date)"
                }

                return updatedDTO
            }
        try await storage.updateOrCreate(dtos: dtos)
    }

}
