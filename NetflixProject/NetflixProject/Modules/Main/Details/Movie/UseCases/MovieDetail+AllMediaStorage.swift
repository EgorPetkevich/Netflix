//
//  DetailsAllMediaStorageUseCase.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import Storage

struct MovieDetailsStorageUseCase:
    MovieDetailsStorageUseCaseProtocol {

    private let storage: MovieStorage

    init(storage: MovieStorage) {
        self.storage = storage
    }

    func fetch(by id: String) async -> MovieDTO? {
        await storage.fetch(by: id)
    }

}
