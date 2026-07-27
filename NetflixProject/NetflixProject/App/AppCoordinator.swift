//
//  AppCoordinator.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import UIKit
import SwiftUI
import Combine
import ComposableArchitecture
import Storage

final class AppCoordinator: Coordinator {

    private weak var splashOverlayView: UIView?

    private var passCodePassed: Bool = false
    private var bag: Set<AnyCancellable> = []

    private let container: Container
    private let windowManager: WindowManager
    private let mediaDataWorker: MediaDataWorker
    private let homeContentLoader: HomeContentLoader

    init(container: Container) {
        self.container = container
        self.windowManager = container.resolve()
        self.mediaDataWorker = container.resolve()
        self.homeContentLoader = container.resolve()
    }

    func startApp() {
        if AppLaunchArguments.isUITesting {
            openUITestFlow()
            return
        }

        if !UDManager.get(.isOnboardingPassed) {
            openOnbording()
        } else if !UDManager.get(.authenticated) {
            openAuth(initial: .login)
        } else if passCodePassed == false {
            openPasscode()
        } else {
            openMainConfig()
        }
    }

    private func openUITestFlow() {
        if AppLaunchArguments.shouldOpenMovieDetails {
            openMovieDetailsForUITests()
        } else if AppLaunchArguments.shouldOpenTvDetails {
            openTvDetailsForUITests()
        } else {
            openMainConfig()
        }
    }

    private func openPasscode() {
        let coordinator = PasscodeCoordinator(container: container)
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.passCodePassed = true
            self?.startApp()
        }

        let viewController = coordinator.start()

        let window = windowManager.get(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    private func openMainConfig() {
        openMain()

        if !AppLaunchArguments.isUITesting {
            showSplashOverlay()
            bindHomeContentLoading()

            Task(priority: .background) {
                await mediaDataWorker.restore()
            }
        }
    }

    private func bindHomeContentLoading() {
        homeContentLoader.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {

                case .ready:
                    self?.hideSplashOverlay()

                default:
                    break
                }
            }
            .store(in: &bag)
    }

    private func showSplashOverlay() {
        let splashVC = SplashScreenVC()
        let window = windowManager.get(type: .main)

        splashVC.view.frame = window.bounds
        window.addSubview(splashVC.view)

        splashOverlayView = splashVC.view
    }

    private func hideSplashOverlay() {
        guard let splashOverlayView else { return }

        UIView.animate(withDuration: 0.3, animations: {
            splashOverlayView.alpha = 0
        }) { [weak self] _ in
            splashOverlayView.removeFromSuperview()
            self?.splashOverlayView = nil
        }
    }

    private func openOnbording() {
        let coordinator = OnboardingCoordinator()
        children.append(coordinator)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.startApp()
        }

        coordinator.onLoginFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.openAuth(initial: .login)
        }

        coordinator.onRegistrationFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.openAuth(initial: .register)
        }

        let viewController = coordinator.start()

        let window = windowManager.get(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    private func openAuth(initial: AuthStartPoint) {
        let nc = UINavigationController()

        let coordinator = AuthCoordinator(
            container: container,
            rootNC: nc,
            startPoint: initial
        )

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.startApp()
        }

        children.append(coordinator)

        let viewController = coordinator.start()

        let window = windowManager.get(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    private func openMain() {
        let coordinator = MainTabBarCoordinator(container: container)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.startApp()
        }

        let viewController = coordinator.start()

        let window = windowManager.get(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }
}

// MARK: - For UI Testing

private extension AppCoordinator {

    private func openMovieDetailsForUITests() {
        let coordinator = MovieDetailsCoordinator(container: container)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.startApp()
        }

        let viewController = coordinator.start(model: MovieDTO.mock())

        let window = windowManager.get(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

    private func openTvDetailsForUITests() {
        let coordinator = TvDetailsCoordinator(container: container)

        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll(where: { $0 == coordinator })
            self?.startApp()
        }

        let viewController = coordinator.start(model: TvDTO.mock())

        let window = windowManager.get(type: .main)
        window.rootViewController = viewController
        window.makeKeyAndVisible()
    }

}
