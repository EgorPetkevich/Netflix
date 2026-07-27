//
//  UDManager.swift
//  NetflixProject
//
//  Created by George Popkich on 1.04.26.
//

import Foundation

final class UDManager {

    enum Keys: String {
        case isOnboardingPassed
        case authenticated
    }

    private static var ud: UserDefaults = .standard

    private init() {}

    static func set(_ key: Keys, value: Bool) {
        ud.set(value, forKey: key.rawValue)
    }

    static func get(_ key: Keys) -> Bool {
        ud.bool(forKey: key.rawValue)
    }

}
