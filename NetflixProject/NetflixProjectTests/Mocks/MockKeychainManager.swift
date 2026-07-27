//
//  MockKeychainManager.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
@testable import NetflixProject

final class MockKeychainManager: KeychainManaging {

    var savedValue: String?

    var didCallDelete: Bool = false

    func save(_ value: String, usage: KeychainUsage) {
        savedValue = value
    }

    func get(_ usage: NetflixProject.KeychainUsage) -> String? {
        savedValue
    }

    func delete(_ usage: NetflixProject.KeychainUsage) {
        didCallDelete = true
        savedValue = nil
    }

}
