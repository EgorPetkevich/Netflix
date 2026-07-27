//
//  MediaDataWorkerService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 5.05.26.
//

import Foundation
import ComposableArchitecture
import Storage

public struct MediaDataWorkerService {
    var updateOrDelete: (any MediaDTODescription) async throws -> Void
    var updateOrCreate: (any MediaDTODescription) async throws -> Void
    var delete: (any MediaDTODescription) async throws -> Void
    var logout: () async -> Void
    var waitingsCount: () async -> Int
    var getWaitings: () async -> [MovieDTO]
    var getDelivered: () async -> [MovieDTO]
}

extension MediaDataWorkerService: DependencyKey {

    public static let liveValue = {
        let mediaDataWorker = MediaDataWorker(
            backup: FireBaseBackupService(),
            storage: AllMediaStorage(),
            notiService: NotificationService()
        )

        return MediaDataWorkerService(
            updateOrDelete: { dto in
                try await mediaDataWorker.updateOrDelete(dto: dto)
            },
            updateOrCreate: { dto in
                try await mediaDataWorker.updateOrCreate(dto: dto)
            },
            delete: { dto in
                try await mediaDataWorker.delete(dto: dto)
            },
            logout: {
                await mediaDataWorker.logout()
            },
            waitingsCount: {
                await mediaDataWorker.waitingsCount()
            },
            getWaitings: {
                await mediaDataWorker.getWaitings()
            },
            getDelivered: {
                await mediaDataWorker.getDelivered()
            }
        )
    }()

}

extension DependencyValues {
    var mediaDataWorker: MediaDataWorkerService {
        get { self[MediaDataWorkerService.self] }
        set { self[MediaDataWorkerService.self] = newValue }
    }
}
