//
//  PassCreateAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import UIKit
import SwiftUI

final class PassCreateAssembler {

    private init() {}

    static func make(
        container: Container,
        coordinator: PassCreateCoordinatorProtocol
    ) -> UIViewController {

        let pinCodeService = PassCreatePinCodeServiceUseCase(
            service: container.resolve()
        )

        let vm = PassCreateViewModel(
            coordinator: coordinator,
            pinCodeService: pinCodeService
        )

        let view = PassCreateView(viewModel: vm)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
