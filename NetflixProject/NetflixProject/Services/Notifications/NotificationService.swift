//
//  NotificationService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import UIKit
import Kingfisher
import Storage

enum NotiServiceError: Error {
    case imagePathNotFound
}

final class NotificationService: NSObject {

    private let notificationCenter = UNUserNotificationCenter.current()

    private let attachmentFileManager = FileManagerService()

    private let logger = Logger(NotificationService.self)

    override init() {
        super.init()
        notificationCenter.delegate = self
    }

    func requestAuthorization() async throws {
        do {
            _ = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
        } catch {
            logger.error("Notification permission error: \(error)")
            throw error
        }
    }

    func makeReleaseNotification(dto: MovieDTO) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await self.requestAuthorization()

                let context = try await self.createContext(with: dto)

                guard let releaseDate = dto.releaseDate?.toDate() else {
                    self.logger.error("Release date not found for movie: \(dto.title)")
                    return
                }

                let triggerDate = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: releaseDate
                )

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: triggerDate,
                    repeats: false
                )

                let request = UNNotificationRequest(
                    identifier: dto.id,
                    content: context,
                    trigger: trigger
                )

                try await self.notificationCenter.add(request)
                self.logger.success("Notification scheduled: \(dto.title)")
            } catch {
                self.logger.error("Notification error: \(error)")
            }
        }
    }

    func updateOrCreateNotification(dto: MovieDTO) {
        makeReleaseNotification(dto: dto)
    }

    func getPendingNotificationIds() async -> [String] {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.map(\.identifier)
    }

    func getDeliveredNotificationIds() async -> [String] {
        let notifications = await notificationCenter.deliveredNotifications()
        return notifications.map { $0.request.identifier }
    }

    func removeNotification(id: String) {
        notificationCenter
            .removePendingNotificationRequests(withIdentifiers: [id])

        notificationCenter
            .removeDeliveredNotifications(withIdentifiers: [id])
    }

    func removeAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        attachmentFileManager.deleteAll()
    }

    private func createContext(
        with dto: MovieDTO
    ) async throws -> UNMutableNotificationContent {

        let content = UNMutableNotificationContent()
        content.title = dto.title
        content.body = "Release date: \(dto.releaseDate ?? "")"
        content.sound = .default

        if let posterPath = dto.posterPath,
           let attachment = try? await makePosterAttachment(
                from: posterPath,
                movieId: dto.id
           ) {
            content.attachments = [attachment]
        }

        return content
    }

    private func makePosterAttachment(
        from posterPath: String,
        movieId: String
    ) async throws -> UNNotificationAttachment {

        guard
            let posterURL = URLBuilder.image(
                type: .poster(path: posterPath),
                size: .w500
            )
        else { throw NotiServiceError.imagePathNotFound }

        let image = try await retrieveImage(from: posterURL)

        return try attachmentFileManager.makeAttachment(
            image: image,
            id: movieId
        )
    }

    private func retrieveImage(from url: URL) async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            KingfisherManager.shared.retrieveImage(with: url) { result in
                switch result {
                case let .success(value):
                    continuation.resume(returning: value.image)
                case let .failure(error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void

    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
