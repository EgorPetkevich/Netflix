//
//  ResetAssembler.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import UIKit

final class ResetAssembler {

    private init() {}

    static func make(container: Container) -> UIViewController {
        let router = ResetRouter()

        let keyBoardHelper = ResetKeyboardHalperUseCase(
            service: container.resolve()
        )

        let inputValidator = ResetInputValidatorUseCase(
            validator: container.resolve()
        )

        let authService = ResetAuthServiceUseCase(
            service: container.resolve()
        )

        let alertService = ResetAlertServiceUseCase(
            service: container.resolve()
        )

        let viewModel = ResetViewModel(
            router: router,
            keyBoardHelper: keyBoardHelper,
            inputValidator: inputValidator,
            authService: authService,
            alertService: alertService
        )

        let viewController = ResetVC(viewModel: viewModel)

        router.rootVC = viewController

        return viewController
    }

}
