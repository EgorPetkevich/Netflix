//
//  MovieDetailsAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import UIKit
import Storage

final class MovieDetailsAssembler {

    private init() {}

    static func make(
        container: Container,
        model: MovieDTO,
        coordinator: MovieDetailsCoordinatorProtocol
    ) -> UIViewController {

        let dataWorker = MovieDetaisMediaDataWorkerUseCase(
            dataWorker: container.resolve()
        )

        let storage = MovieDetailsStorageUseCase(
            storage: container.resolve()
        )

        let purchaseService = MovieDetailsPurchesServUseCase(service: container.resolve())

        let vm = MovieDetailsVM(
            model: model,
            coordinator: coordinator,
            storage: storage,
            dataWorker: dataWorker,
            purchaseService: purchaseService
        )
        let vc = MovieDetailsVC(viewModel: vm)

        return vc
    }

}
