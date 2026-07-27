//
//  AuthService+DependencyValues.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.04.26.
//

import Foundation
import ComposableArchitecture

extension DependencyValues {
    var authService: AuthServiceProtocol {
        get { self[AuthServiceKey.self] }
        set { self[AuthServiceKey.self] = newValue }
    }
}

private enum AuthServiceKey: DependencyKey {
    static let liveValue: AuthServiceProtocol = AuthService()
}
