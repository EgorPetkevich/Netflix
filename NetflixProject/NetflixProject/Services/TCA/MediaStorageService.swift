//
//  MediaStorageService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 30.04.26.
//

import Foundation
import ComposableArchitecture
import Storage

public struct MediaStorageService {
    var fetch: () async -> [any MediaDTODescription]
    var fetchSingle: (String) async -> (any MediaDTODescription)?
    var save: (any MediaDTODescription) async throws -> Void
    var delete: (any MediaDTODescription) async throws -> Void
    var counts: () async throws -> (favorites: Int, bookmarked: Int)
}

extension MediaStorageService: DependencyKey {

    public static let liveValue = {
        let storage = AllMediaStorage()

        return MediaStorageService(
            fetch: {
                await storage.fetchAll()
            },
            fetchSingle: { id in
                await storage.fetch(by: id)
            },
            save: { model in
                try await storage.updateOrCreate(dto: model)
            },
            delete: { model in
                try await storage.delete(dto: model)
            },
            counts: {
                try await storage.counts()
            }
        )
    }()

}

extension DependencyValues {
    var mediaStorage: MediaStorageService {
        get { self[MediaStorageService.self] }
        set { self[MediaStorageService.self] = newValue }
    }
}
