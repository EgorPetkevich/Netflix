//
//  MediaDataWorker.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 5.05.26.
//

import Foundation
import Storage

protocol MediaDataWorkerAllStoragesUseCaseProtocol {
    func updateOrCreate(dto: any MediaDTODescription) async throws
    func delete(dto: any MediaDTODescription) async throws
    func fetchMovies(by ids: [String]) async -> [MovieDTO]
}

protocol MediaDataWorkerBackupUseCaseProtocol {
    func send(dto: any MediaDTODescription)
    func delete(dto: any MediaDTODescription)
    func load() async throws -> [any MediaDTODescription]
}

protocol MediaDataWorkerNotiServiceUseCaseProtocol {
    func makeNotifications(from dtos: [MovieDTO])
    func removeNotifications(ids: [String])
    func removeAllNotifications()
    func getPendingNotificationIds() async -> [String]
    func getDeliveredNotificationIds() async -> [String]
}

final class MediaDataWorker {

    private let backup: MediaDataWorkerBackupUseCaseProtocol
    private let storage: MediaDataWorkerAllStoragesUseCaseProtocol
    private let notiService: MediaDataWorkerNotiServiceUseCaseProtocol

    init(
        backup: MediaDataWorkerBackupUseCaseProtocol,
        storage: MediaDataWorkerAllStoragesUseCaseProtocol,
        notiService: MediaDataWorkerNotiServiceUseCaseProtocol
    ) {
        self.backup = backup
        self.storage = storage
        self.notiService = notiService
    }

    func updateOrDelete(dto: any MediaDTODescription) async throws {
        if shouldDelete(dto: dto) {
            try await storage.updateOrCreate(dto: dto)
            try await delete(dto: dto)
        } else {
            try await updateOrCreate(dto: dto)
        }
    }

    func updateOrCreate(dto: any MediaDTODescription) async throws {
        try await storage.updateOrCreate(dto: dto)
        backup.send(dto: dto)

        if let movie = dto as? MovieDTO {
            updateNotificationIfNeeded(movie)
        }
    }

    func delete(dto: any MediaDTODescription) async throws {
        try await storage.delete(dto: dto)
        backup.delete(dto: dto)

        if let movie = dto as? MovieDTO {
            notiService.removeNotifications(ids: [movie.id])
        }
    }

    func restore() async {
        do {
            let dtos = try await backup.load()

            for dto in dtos {
                try await storage.updateOrCreate(dto: dto)
            }

            let subscribedMovies = dtos
                .compactMap { $0 as? MovieDTO }
                .filter(\.isSubscribed)

            notiService.makeNotifications(from: subscribedMovies)

        } catch {
            print("Restore failed: \(error)")
        }
    }

    func logout() async {
        do {
            try StorageService.deleteModels()

            notiService.removeAllNotifications()

        } catch {
            print("Logout failed: \(error)")
        }
    }

    func waitingsCount() async -> Int {
        await notiService.getPendingNotificationIds().count
    }

    func getWaitings() async -> [MovieDTO] {
        async let ids = notiService.getPendingNotificationIds()

        return await storage.fetchMovies(by: ids)
    }

    func getDelivered() async -> [MovieDTO] {
        async let ids = notiService.getDeliveredNotificationIds()

        return await storage.fetchMovies(by: ids)
    }

    private func updateNotificationIfNeeded(_ movie: MovieDTO) {
        if movie.isSubscribed {
            notiService.makeNotifications(from: [movie])
        } else {
            notiService.removeNotifications(ids: [movie.id])
        }
    }

    private func shouldDelete(dto: any MediaDTODescription) -> Bool {
        if let movie = dto as? MovieDTO {
            return !movie.isBookmarked && !movie.isFavorite && !movie.isSubscribed
        }

        return !dto.isBookmarked && !dto.isFavorite
    }

}
