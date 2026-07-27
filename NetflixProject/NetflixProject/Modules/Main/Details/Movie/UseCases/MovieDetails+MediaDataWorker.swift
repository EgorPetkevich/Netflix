//
//  DetaisMediaDataWorkerUseCase.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import Foundation
import Storage

struct MovieDetaisMediaDataWorkerUseCase:
    MovieDetaisMediaDataWorkerUseCaseProtocol {

    private let dataWorker: MediaDataWorker

    init(dataWorker: MediaDataWorker) {
        self.dataWorker = dataWorker
    }

    func updateOrDelete(dto: MovieDTO) async throws {
        try await dataWorker.updateOrDelete(dto: dto)
    }

}
