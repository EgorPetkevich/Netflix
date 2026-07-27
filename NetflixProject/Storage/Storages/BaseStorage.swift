//
//  BaseStorage.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

public class BaseStorage<DTO: MediaDTODescription> {

    public init() {}

    public func fetch() async -> [any MediaDTODescription] {
        let result = fetchMO(with: .byDate())
        return result.compactMap { $0.toDTO() }
    }

    public func fetch(by id: String) async -> (any MediaDTODescription)? {
        let result = fetchMO(with: .byId(id)).first
        return result?.toDTO()
    }

    public func fetch(by ids: [String]) async -> [any MediaDTODescription] {
        var result: [any MediaDTODescription] = []

        for id in ids {
            if let dto = await fetch(by: id) {
                result.append(dto)
            }
        }

        return result
    }

    public func updateOrCreate(dto: any MediaDTODescription) async throws {
        let context = StorageService.shared.mainContext
        if let mo = fetchMO(with: .byId(dto.id)).first {
            mo.apply(dto: dto)
        } else {
            let mo = dto.createMO()
            context.insert(mo)
        }

        try context.save()
    }

    public func updateOrCreate(dtos: [any MediaDTODescription]) async throws {
        let context = StorageService.shared.mainContext

        for dto in dtos {
            if let mo = fetchMO(with: .byId(dto.id)).first {
                mo.apply(dto: dto)
            } else {
                let mo = dto.createMO()
                context.insert(mo)
            }
        }

        try context.save()
    }

    public func delete(id: String) async throws {
        let context = StorageService.shared.mainContext
        if let mo = fetchMO(with: .byId(id)).first {
            context.delete(mo)
            try context.save()
        }
    }

    public func favoritesCount() async throws -> Int {
        try await count(
            predicate: #Predicate { $0.isFavorite == true }
        )
    }

    public func bookmarkedCount() async throws -> Int {
        try await count(
            predicate: #Predicate { $0.isBookmarked == true }
        )
    }

    private func fetchMO(
        with fetchDescriptor: FetchDescriptor<DTO.MO>
    ) -> [DTO.MO] {
        let context = StorageService.shared.mainContext
        return (try? context.fetch(fetchDescriptor)) ?? []
    }
}

extension BaseStorage {

    func count(
        predicate: Predicate<DTO.MO>? = nil
    ) async throws -> Int {
        let context = StorageService.shared.mainContext
        let descriptor = FetchDescriptor<DTO.MO>(
            predicate: predicate
        )

        return try context.fetch(descriptor).count
    }
}
