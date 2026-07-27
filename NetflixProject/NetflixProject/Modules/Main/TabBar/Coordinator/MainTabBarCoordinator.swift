//
//  MainTabBarCoordinator.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit

final class MainTabBarCoordinator: Coordinator {

    private let container: Container

    private var rootVC: UIViewController?
    private weak var tabBarController: UITabBarController?

    init(container: Container) {
        self.container = container
    }

    override func start() -> UIViewController {
        let tabBar = MainTabBarVC()
        tabBar.viewControllers = [
            makeHomeModule(),
            makeSearchModule(),
            makeFavoritesModule(),
            makeProfileModule()
        ]
        self.tabBarController = tabBar
        rootVC = tabBar
        return tabBar
    }

    private func makeHomeModule() -> UIViewController {
        let coordinator = HomeCoordinator(container: container)
        children.append(coordinator)
        coordinator.onDidFinish = { [weak self] coordinator in
            self?.children.removeAll { coordinator == $0 }
            self?.finish()
        }
        return coordinator.start()
    }

    private func makeSearchModule() -> UIViewController {
        let viewController = SearchAssembler.make(container: container)

        viewController.tabBarItem = UITabBarItem(
            title: "Search",
            image: .init(systemName: "magnifyingglass"),
            tag: .zero
        )
        return viewController
    }

    private func makeFavoritesModule() -> UIViewController {
        let viewController = FavoritesAssembler.make(container: container)
        viewController.tabBarItem = UITabBarItem(
            title: "Favorites",
            image: .init(systemName: "heart"),
            tag: .zero
        )
        return viewController
    }

    private func makeProfileModule() -> UIViewController {
        let viewController = ProfileAssembler.make(
            container: container,
            onLogOut: {
                self.finish()
            },
            onOpenFavorite: {
                self.tabBarController?.selectedIndex = 2
        })

        viewController.tabBarItem = UITabBarItem(
            title: "Profile",
            image: .init(systemName: "person.crop.circle.fill"),
            tag: .zero
        )
        return viewController
    }

}
