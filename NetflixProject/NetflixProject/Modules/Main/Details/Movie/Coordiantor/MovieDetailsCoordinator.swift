//
//  MovieDetailsCoordinator.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 8.05.26.
//

import UIKit
import Storage

final class MovieDetailsCoordinator: Coordinator {

    var onPaywallDismiss: (() -> Void)?

    private var rootVC: UIViewController?

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func start(model: MovieDTO) -> UIViewController {
        let vc = MovieDetailsAssembler.make(
            container: container,
            model: model,
            coordinator: self
        )
        rootVC = vc
        return vc
    }

}

extension MovieDetailsCoordinator: MovieDetailsCoordinatorProtocol {

    func showPaywall() {
        guard let rootVC else { return }

        var paywallVC: UIViewController?

        let vc = PaywallAssembler.make(container: container) {
            paywallVC?.dismiss(animated: true)
            self.onPaywallDismiss?()
        }

        paywallVC = vc

        vc.modalPresentationStyle = .fullScreen

        rootVC.present(vc, animated: true)
    }

}
