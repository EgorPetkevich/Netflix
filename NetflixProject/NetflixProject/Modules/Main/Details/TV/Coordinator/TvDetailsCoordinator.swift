//
//  DetailsCoordinator.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 16.04.26.
//

import UIKit
import Storage

final class TvDetailsCoordinator: Coordinator {

    var onPaywallDismiss: (() -> Void)?

    private var rootVC: UIViewController?

    private let container: Container

    init(container: Container) {
        self.container = container
    }

    func start(model: TvDTO) -> UIViewController {
        let vc = TvDetailsAssembler.make(
            container: container,
            model: model,
            coordinator: self
        )
        rootVC = vc
        return vc
    }

}

extension TvDetailsCoordinator: TvDetailsCoordinatorProtocol {

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
