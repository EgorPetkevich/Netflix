//
//  TvDetailsAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import UIKit
import Storage

final class TvDetailsAssembler {

    private init() {}

    static func make(
        container: Container,
        model: TvDTO,
        coordinator: TvDetailsCoordinatorProtocol
    ) -> UIViewController {

        let dataWorker = TvDetaisMediaDataWorkerUseCase(
            dataWorker: container.resolve()
        )

        let storage = TvDetailsAllMediaStorageUseCase(
            allMediaStorage: container.resolve()
        )

        let purchaseService = TvDetailsPurchesServUseCase(service: container.resolve())

        let vm = TvDetailsVM(
            model: model,
            coordinator: coordinator,
            storage: storage,
            dataWorker: dataWorker,
            purchaseService: purchaseService
        )
        let vc = TvDetailsVC(viewModel: vm)

        return vc
    }

}
