//
//  Details+MediaDataWorker.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 5.05.26.
//

import Foundation
import Storage

struct TvDetaisMediaDataWorkerUseCase:
    TvDetaisMediaDataWorkerUseCaseProtocol {

    private let dataWorker: MediaDataWorker

    init(dataWorker: MediaDataWorker) {
        self.dataWorker = dataWorker
    }

    func updateOrDelete(dto: any MediaDTODescription) async throws {
        try await dataWorker.updateOrDelete(dto: dto)
    }

}
