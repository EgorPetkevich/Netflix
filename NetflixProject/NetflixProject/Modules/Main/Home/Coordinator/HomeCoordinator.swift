//
//  HomeCoordinator.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import Storage

final class HomeCoordinator: Coordinator {

    private var rootNC: UINavigationController?

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    override func start() -> UIViewController {
        let vc = HomeAssembler.make(container: container, coordinator: self)
        let nc = UINavigationController(rootViewController: vc)

        rootNC = nc
        return nc
    }

}

extension HomeCoordinator: HomeCoordinatorProtocol {

    func showTvDetails(for model: TvDTO) {
        guard let rootNC else { return }

        let coordinator = TvDetailsCoordinator(container: container)
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.rootNC?.popViewController(animated: true)
        }

        let vc = coordinator.start(model: model)

        rootNC.pushViewController(vc, animated: true)
    }

    func showMovieDetails(for model: MovieDTO) {
        guard let rootNC else { return }

        let coordinator = MovieDetailsCoordinator(container: container)
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.rootNC?.popViewController(animated: true)
        }

        let vc = coordinator.start(model: model)

        rootNC.pushViewController(vc, animated: true)
    }

    func showCatalog(with section: MediaListSection) {
        guard let rootNC else { return }

        let coordinator = MediaCatalogCoordinator(rootNC: rootNC, container: container)
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.rootNC?.popViewController(animated: true)
        }

        let vc = coordinator.start(section: section)

        rootNC.pushViewController(vc, animated: true)
    }

    func showPaywall() {
        guard let rootNC else { return }

        var viewController: UIViewController?

        let paywallVC = PaywallAssembler.make(container: container) {
            viewController?.dismiss(animated: true)
        }

        viewController = paywallVC
        paywallVC.modalPresentationStyle = .fullScreen

        rootNC.present(paywallVC, animated: true)
    }

}
