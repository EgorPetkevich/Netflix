//
//  PassConfirmAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import UIKit
import SwiftUI

final class PassConfirmAssembler {

    private init() {}

    static func make(
        container: Container,
        coordinator: PassConfirmCoordinator,
    ) -> UIViewController {

        let pinCodeService = PassConfirmPinCodeServiceUseCase(
            service: container.resolve()
        )

        let vm = PassConfirmViewModel(
            coordinator: coordinator,
            pinCodeService: pinCodeService
        )

        let view = PassConfirmView(viewModel: vm)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
