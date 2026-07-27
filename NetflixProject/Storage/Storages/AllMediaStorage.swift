//
//  AllMediaStorage.swift
//  Storage
//
//  Created by Egor Petkevich on 29.04.26.
//

import Foundation
import SwiftData

public final class AllMediaStorage {

    private let movies = MovieStorage()
    private let tvs = TVStorage()
    private let persons = PersonStorage()

    public init() {}

    public func fetchAll() async -> [any MediaDTODescription] {
        async let moviesFetch = movies.fetch()
        async let tvsFetch = tvs.fetch()
        async let personsFetch = persons.fetch()

        return await (moviesFetch + tvsFetch + personsFetch)
    }

    public func fetch(by id: String) async -> (any MediaDTODescription)? {
        if let movie = await movies.fetch(by: id) {
            return movie
        }
        if let tv = await tvs.fetch(by: id) {
            return tv
        }
        if let person = await persons.fetch(by: id) {
            return person
        }
        return nil
    }

    public func fetchMovies(by ids: [String]) async -> [MovieDTO] {
        let movies = await movies.fetch(by: ids)
        return movies
    }

    public func updateOrCreate(dto model: any MediaDTODescription) async throws {
        switch model {
        case let movie as MovieDTO:
            try await movies.updateOrCreate(dto: movie)
        case let tv as TvDTO:
            try await tvs.updateOrCreate(dto: tv)
        case let person as PersonDTO:
            try await persons.updateOrCreate(dto: person)
        default:
            break
        }
    }

    public func delete(dto model: any MediaDTODescription) async throws {
        switch model {
        case let movie as MovieDTO:
            if try !isUsedInPerson(mediaId: movie.id) {
                try await movies.delete(id: movie.id)
            }
        case let tv as TvDTO:
            if try !isUsedInPerson(mediaId: tv.id) {
                try await tvs.delete(id: tv.id)
            }
        case let person as PersonDTO:
            try await persons.delete(id: person.id)
        default:
            break
        }
    }

    private func isUsedInPerson(mediaId: String) throws -> Bool {
        let descriptor = FetchDescriptor<PersonMO>(
            predicate: #Predicate { person in
                person.knownForMovies.contains { $0.id == mediaId } ||
                person.knownForTvs.contains { $0.id == mediaId }
            }
        )
        return try !StorageService.shared.mainContext.fetch(descriptor).isEmpty
    }

    public func counts() async throws -> (favorites: Int, bookmarked: Int) {

        async let movieFav = movies.favoritesCount()
        async let tvFav = tvs.favoritesCount()
        async let personFav = persons.favoritesCount()

        async let movieBook = movies.bookmarkedCount()
        async let tvBook = tvs.bookmarkedCount()
        async let personBook = persons.bookmarkedCount()

        let favorites = try await (movieFav + tvFav + personFav)
        let bookmarked = try await (movieBook + tvBook + personBook)

        return (favorites, bookmarked)
    }

}
