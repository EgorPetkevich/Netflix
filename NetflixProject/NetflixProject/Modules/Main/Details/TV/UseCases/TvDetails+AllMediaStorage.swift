//
//  Details+AllMediaStorage.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 5.05.26.
//

import Storage

struct TvDetailsAllMediaStorageUseCase:
    TvDetailsAllMediaStorageUseCaseProtocol {

    private let allMediaStorage: AllMediaStorage

    init(allMediaStorage: AllMediaStorage) {
        self.allMediaStorage = allMediaStorage
    }

    func fetch(by id: String) async -> (any Storage.MediaDTODescription)? {
        await allMediaStorage.fetch(by: id)
    }

}
