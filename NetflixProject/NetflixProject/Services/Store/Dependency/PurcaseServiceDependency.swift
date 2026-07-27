//
//  PurcaseServiceDependency.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 18.05.26.
//

import ComposableArchitecture

private enum PurchaseServiceKey: DependencyKey {
    static let liveValue: PurchaseServiceProtocol = PurchaseService()
}

extension DependencyValues {
    var purchaseService: PurchaseServiceProtocol {
        get { self[PurchaseServiceKey.self] }
        set { self[PurchaseServiceKey.self] = newValue }
    }
}
