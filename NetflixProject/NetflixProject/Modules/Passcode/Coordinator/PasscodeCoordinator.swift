//
//  PassCoordinator.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import UIKit
import Swift
import SwiftUI

final class PasscodeCoordinator: Coordinator {

    private let container: Container
    private var rootNC: UINavigationController?

    private let keyChainManager: KeychainManaging

    init(container: Container) {
        self.container = container
        self.keyChainManager = container.resolve()
    }

    override func start() -> UIViewController {
        let initialVC: UIViewController

        if keyChainManager.get(.passcode) != nil {
            initialVC = PassLoginAssembler.make(
                container: container,
                coordinator: self
            )
        } else {
            initialVC = PassCreateAssembler.make(
                container: container,
                coordinator: self
            )
        }

        let nc = UINavigationController(rootViewController: initialVC)
        self.rootNC = nc
        return nc
    }

    func openLogin(replaceStack: Bool = false) {
        let vc = PassLoginAssembler.make(
            container: container,
            coordinator: self
        )

        if replaceStack {
            rootNC?.setViewControllers([vc], animated: true)
        } else {
            rootNC?.pushViewController(vc, animated: true)
        }
    }

    func openCreate() {
        let vc = PassCreateAssembler.make(
            container: container,
            coordinator: self
        )
        rootNC?.pushViewController(vc, animated: true)
    }

    func openConfirm() {
        let vc = PassConfirmAssembler.make(
            container: container,
            coordinator: self
        )
        rootNC?.pushViewController(vc, animated: true)
    }
}

extension PasscodeCoordinator: PassLoginCoordinatorProtocol {

    func onLoginSuccess() {
        self.finish()
    }

}

extension PasscodeCoordinator: PassCreateCoordinatorProtocol {

    func onCreateSuccess() {
        openConfirm()
    }

}

extension PasscodeCoordinator: PassConfirmCoordinator {

    func onConfirmSuccess() {
        openLogin(replaceStack: true)
    }

    func popPassConfirm() {
        rootNC?.popViewController(animated: true)
    }
}
