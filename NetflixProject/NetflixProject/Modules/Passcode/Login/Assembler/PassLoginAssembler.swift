//
//  PassLoginAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 6.05.26.
//

import UIKit
import SwiftUI

final class PassLoginAssembler {

    private init() {}

    static func make(
        container: Container,
        coordinator: PassLoginCoordinatorProtocol
    ) -> UIViewController {

        let identityService = PassLoginIndentifyServiceUseCase(
            service: container.resolve()
        )

        let pinCodeService = PassLoginPinCodeServiceUseCase(
            service: container.resolve()
        )

        let vm = PassLoginViewModel(
            coordinator: coordinator,
            pinCodeService: pinCodeService,
            identityService: identityService
        )

        let view = PassLoginView(viewModel: vm)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
