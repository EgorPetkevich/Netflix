//
//  OnboardingAssembler.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit

final class OnboardingAssembler {

    private init() {}

    static func make(
        coordinator: OnboardingCoordinatorProtocol
    ) -> UIViewController {
        let viewModel = OnboardingVM(coordinator: coordinator)
        let viewController = OnboardingVC(viewModel: viewModel)
        return viewController
    }

}
