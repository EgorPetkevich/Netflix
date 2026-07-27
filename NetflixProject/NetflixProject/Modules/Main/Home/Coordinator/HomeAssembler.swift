//
//  HomeAssembler.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit

final class HomeAssembler {

    private init() {}

    static func make(
        container: Container,
        coordinator: HomeCoordinatorProtocol
    ) -> UIViewController {

        let contentLoader: HomeContentLoaderProtocol = container.resolve()
        let alertService = HomeAlertServiceUseCase(service: container.resolve())

        let vm = HomeVM(
            coordinator: coordinator,
            contentLoader: contentLoader,
            alertService: alertService
        )

        let vc = HomeVC(viewModel: vm, adapter: MainListAdapter())

        return vc
    }

}
