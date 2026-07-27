//
//  SearchAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import UIKit
import SwiftUI
import ComposableArchitecture

final class SearchAssembler {

    private init() {}

    static func make(container: Container) -> UIViewController {
        let store = Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }

        let view = SearchView(container: container, store: store)
        let viewController = UIHostingController(rootView: view)

        return viewController
    }

}
