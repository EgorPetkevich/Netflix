//
//  OnboardingCoordinator.swift
//  NetflixProject
//
//  Created by George Popkich on 27.03.26.
//

import UIKit

final class OnboardingCoordinator: Coordinator {

    var onLoginFinish: ((Coordinator) -> Void)?
    var onRegistrationFinish: ((Coordinator) -> Void)?

    private var rootNC: UINavigationController?

    override func start() -> UIViewController {
        let viewController = OnboardingAssembler.make(coordinator: self)
        return viewController
    }

}

extension OnboardingCoordinator: OnboardingCoordinatorProtocol {

    func openLogin() {
        onLoginFinish?(self)
    }

    func openRegistration() {
        onRegistrationFinish?(self)
    }

}
