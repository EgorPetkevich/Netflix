//
//  MockMediaBackup.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
@testable import NetflixProject
@testable import Storage

final class MockMediaBackup: MediaDataWorkerBackupUseCaseProtocol {

    var sentDTOs: [any MediaDTODescription] = []
    var deletedDTOs: [any MediaDTODescription] = []

    var dtosToLoad: [any MediaDTODescription] = []

    func send(dto: any MediaDTODescription) {
        sentDTOs.append(dto)
    }

    func delete(dto: any MediaDTODescription) {
        deletedDTOs.append(dto)
    }

    func load() async throws -> [any MediaDTODescription] {
        dtosToLoad
    }
}
