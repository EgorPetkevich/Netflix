//
//  AuthCoordinator.swift
//  NetflixProject
//
//  Created by George Popkich on 3.04.26.
//

import UIKit

final class AuthCoordinator: Coordinator {

    private let rootNC: UINavigationController
    private let container: Container
    private let startPoint: AuthStartPoint

    init(
        container: Container,
        rootNC: UINavigationController,
        startPoint: AuthStartPoint
    ) {
        self.container = container
        self.rootNC = rootNC
        self.startPoint = startPoint
    }

    override func start() -> UIViewController {
        switch startPoint {
        case .login:
            let login = LoginAssembler.make(container: container, coordinator: self)
            rootNC.setViewControllers([login], animated: false)

        case .register:
            let login = LoginAssembler.make(container: container, coordinator: self)
            let register = RegisterAssembler.make(container: container, coordinator: self)
            rootNC.setViewControllers([login, register], animated: false)
        }

        return rootNC
    }
}

extension AuthCoordinator: LoginCoordinatorProtocol {

    func openReset() {
        let vc = ResetAssembler.make(container: container)
        vc.modalPresentationStyle = .fullScreen
        rootNC.present(vc, animated: true)
    }

    func presentGoogleAuth() async throws {
        try await AuthService.signInWithGoogle(viewController: rootNC)
    }

    func openRegister() {
        let vc = RegisterAssembler.make(container: container, coordinator: self)
        rootNC.pushViewController(vc, animated: true)
    }

}

extension AuthCoordinator: RegisterCoordinatorProtocol {

    func openLogin() {
        rootNC.popViewController(animated: true)
    }

}
