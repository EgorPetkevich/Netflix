//
//  UDManagerTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import XCTest
@testable import NetflixProject

final class UDManagerTests: XCTestCase {

    override func setUp() {
        super.setUp()
        removeValues()
    }

    override func tearDown() {
        removeValues()
        super.tearDown()
    }

    func test_get_whenValueWasNotSet_returnsFalse() {
        XCTAssertFalse(UDManager.get(.authenticated))
    }

    func test_set_whenValueIsTrue_storesTrue() {
        UDManager.set(.isOnboardingPassed, value: true)

        XCTAssertTrue(UDManager.get(.isOnboardingPassed))
    }

    func test_set_whenValueChanges_updatesStoredValue() {
        UDManager.set(.authenticated, value: true)

        UDManager.set(.authenticated, value: false)

        XCTAssertFalse(UDManager.get(.authenticated))
    }

    func test_set_keepsKeysIndependent() {
        UDManager.set(.isOnboardingPassed, value: true)
        UDManager.set(.authenticated, value: false)

        XCTAssertTrue(UDManager.get(.isOnboardingPassed))
        XCTAssertFalse(UDManager.get(.authenticated))
    }
}

private extension UDManagerTests {
    func removeValues() {
        UserDefaults.standard.removeObject(
            forKey: UDManager.Keys.isOnboardingPassed.rawValue
        )
        UserDefaults.standard.removeObject(
            forKey: UDManager.Keys.authenticated.rawValue
        )
    }
}
