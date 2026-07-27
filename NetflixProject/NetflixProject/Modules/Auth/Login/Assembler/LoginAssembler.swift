//
//  LoginAssembler.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import UIKit

final class LoginAssembler {

    private init() {}

    static func make(
        container: Container,
        coordinator: LoginCoordinatorProtocol
    ) -> UIViewController {
        let keyBoardHelper = LoginKeyboardHelperUseCase(
            service: container.resolve()
        )

        let inputValidator = LoginInputValidatorUseCase(
            validator: container.resolve()
        )

        let authService = LoginAuthServiceUseCase(
            service: container.resolve()
        )

        let alertService = LoginAlertServiceUseCase(
            service: container.resolve()
        )

        let viewModel = LoginVM(
            coordinator: coordinator,
            keyBoardHelper: keyBoardHelper,
            inputValidator: inputValidator,
            authService: authService,
            alertService: alertService
        )
        let viewController = LoginVC(viewModel: viewModel)
        return viewController
    }

}
