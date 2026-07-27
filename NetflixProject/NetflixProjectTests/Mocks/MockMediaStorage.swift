//
//  MockMediaStorage.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
@testable import NetflixProject
@testable import Storage

final class MockMediaStorage: MediaDataWorkerAllStoragesUseCaseProtocol {

    var updatedDTOs: [any MediaDTODescription] = []
    var deletedDTOs: [any MediaDTODescription] = []

    var fetchMoviesIds: [String] = []
    var moviesToReturn: [MovieDTO] = []

    func updateOrCreate(dto: any MediaDTODescription) async throws {
        updatedDTOs.append(dto)
    }

    func delete(dto: any MediaDTODescription) async throws {
        deletedDTOs.append(dto)
    }

    func fetchMovies(by ids: [String]) async -> [MovieDTO] {
        fetchMoviesIds = ids
        return moviesToReturn
    }
}
