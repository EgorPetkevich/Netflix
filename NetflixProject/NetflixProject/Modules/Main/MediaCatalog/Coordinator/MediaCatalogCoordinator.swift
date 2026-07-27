//
//  MediaCatalogCoordinator.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import UIKit
import Storage

final class MediaCatalogCoordinator: Coordinator {

    private let container: Container

    private let rootNC: UINavigationController

    init(rootNC: UINavigationController, container: Container) {
        self.container = container
        self.rootNC = rootNC
    }

    func start(section: MediaListSection) -> UIViewController {
        return MediaCatalogAssembler.make(
            container: container,
            section: section,
            coordinator: self
        )
    }

}

extension MediaCatalogCoordinator: MediaCatalogCoordinatorProtocol {

    func showTvDetails(for model: TvDTO) {
        let coordinator = TvDetailsCoordinator(container: container)
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.rootNC.popViewController(animated: true)
        }

        let vc = coordinator.start(model: model)

        rootNC.pushViewController(vc, animated: true)
    }

    func showMovieDetails(for model: MovieDTO) {
        let coordinator = MovieDetailsCoordinator(container: container)
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.rootNC.popViewController(animated: true)
        }

        let vc = coordinator.start(model: model)

        rootNC.pushViewController(vc, animated: true)
    }

}
