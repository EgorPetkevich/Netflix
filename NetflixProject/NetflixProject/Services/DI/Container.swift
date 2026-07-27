//
//  Container.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import Foundation

final class Container {

    private var lazyDependencies: [String: () -> Any] = [:]

    private var dependencies: [String: Any] = [:]

    func lazyRegister<T>(_ clousure: @escaping () -> T) {
        lazyDependencies["\(T.self)"] = clousure
    }

    private func register<T>(_ deps: T) {
        dependencies["\(T.self)"] = deps
    }

    func resolve<T>() -> T {
        if let deps = dependencies["\(T.self)"] {
            // swiftlint:disable:next force_cast
            return deps as! T
        }

        // swiftlint:disable:next force_cast
        let deps = lazyDependencies["\(T.self)"]?() as! T
        lazyDependencies["\(T.self)"] = nil

        register(deps)

        return deps
    }

}
