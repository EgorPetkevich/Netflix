//
//  FavoritesAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 24.04.26.
//

import UIKit
import SwiftUI
import ComposableArchitecture

final class FavoritesAssembler {

    private init() {}

    static func make(container: Container) -> UIViewController {
        let store = Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }

        let view = FavoritesView(container: container, store: store)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
