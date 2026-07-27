//
//  RegisterAssembler.swift
//  NetflixProject
//
//  Created by George Popkich on 2.04.26.
//

import SwiftUI

final class RegisterAssembler {

    private init() {}

    static func make(
        container: Container,
        coordinator: RegisterCoordinatorProtocol
    ) -> UIViewController {

        let alertService: AlertService = container.resolve()
        let inputValidator: InputValidator = container.resolve()
        let authService: AuthService = container.resolve()

        let viewModel = RegisterVM(
            coordinator: coordinator,
            inputValidator: inputValidator,
            authService: authService,
            alertService: alertService
        )

        let view = RegisterView(viewModel: viewModel)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
