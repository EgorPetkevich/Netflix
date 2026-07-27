//
//  SceneDelegate.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import UIKit
import GoogleSignIn
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var appCoordinator: AppCoordinator?

    @Dependency(\.themeService) var themeService

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let container: Container = ContainerConfigurator.make()
        container.lazyRegister { WindowManager(windowScene: windowScene) }

        appCoordinator = AppCoordinator(container: container)
        appCoordinator?.startApp()

        let savedTheme = themeService.getTheme()
        windowScene.windows.forEach { window in
            window.overrideUserInterfaceStyle = savedTheme.userInterfaceStyle
        }
    }

    func scene(
        _ scene: UIScene,
        openURLContexts URLContexts: Set<UIOpenURLContext>
    ) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

}
