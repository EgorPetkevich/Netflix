//
//  MovieStorage.swift
//  Storage
//
//  Created by Egor Petkevich on 11.05.26.
//

import Foundation

public final class MovieStorage: BaseStorage<MovieDTO> {

    public func fetch(by id: String) async -> MovieDTO? {
        if let movie = await super.fetch(by: id) {
            return movie as? MovieDTO
        }
        return nil
    }

    public func fetch(by ids: [String]) async -> [MovieDTO] {
        await withTaskGroup(of: MovieDTO?.self) { group in

            ids.forEach { id in
                group.addTask {
                    await self.fetch(by: id)
                }
            }

            var movies: [MovieDTO] = []

            for await movie in group {
                if let movie {
                    movies.append(movie)
                }
            }

            return movies
        }
    }

    public func updateOrCreate(dto: MovieDTO) async throws {
        try await super.updateOrCreate(dto: dto)
    }

}
