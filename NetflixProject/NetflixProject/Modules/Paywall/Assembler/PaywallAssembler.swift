//
//  PaywallAssembler.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.05.26.
//

import UIKit
import SwiftUI
import ComposableArchitecture

final class PaywallAssembler {

    private init() {}

    static func make(
        container: Container,
        onClose: @escaping () -> Void
    ) -> UIViewController {
        let store = Store(initialState: PaywallFeature.State()) {
            PaywallFeature(onClose: onClose)
        }

        let view = PaywallView(store: store)

        return UIHostingController(rootView: view)
    }
}
