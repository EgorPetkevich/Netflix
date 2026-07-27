//
//  ProfileAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import UIKit
import SwiftUI
import ComposableArchitecture

final class ProfileAssembler {

    private init() {}

    static func make(
        container: Container,
        onLogOut: @escaping () -> Void,
        onOpenFavorite: @escaping () -> Void
    ) -> UIViewController {
        let store = Store(initialState: ProfileFeature.State()) {
            ProfileFeature()
        }

        let view = ProfileView(
            container: container,
            onLogout: onLogOut,
            onOpenFavorite: onOpenFavorite,
            store: store
        )
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
