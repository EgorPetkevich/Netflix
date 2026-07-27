//
//  PinCodeServiceTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import XCTest
 @testable import NetflixProject

 final class PinCodeServiceTests: XCTestCase {

    private var keychain: MockKeychainManager!
    private var sut: PinCodeService!

    override func setUp() {
        super.setUp()
        keychain = MockKeychainManager()
        sut = PinCodeService(keychain: keychain)
    }

    override func tearDown() {
        sut = nil
        keychain = nil
        super.tearDown()
    }

    func test_validateUnconfirmed_whenPinsAreEqual_returnsTrue() {
        sut.unconfirmedPin = "1234"

        let result = sut.validateUnconfirmed(pin: "1234")

        XCTAssertTrue(result)
    }

    func test_validateUnconfirmed_whenPinsAreDifferent_returnsFalse() {
        sut.unconfirmedPin = "1234"

        let result = sut.validateUnconfirmed(pin: "0000")

        XCTAssertFalse(result)
    }

    func test_validateUnconfirmed_whenUnconfirmedPinIsNil_returnsFalse() {
        sut.unconfirmedPin = nil

        let result = sut.validateUnconfirmed(pin: "1234")

        XCTAssertFalse(result)
    }

    func test_save_savesPinToKeychain() throws {
        try sut.save(pin: "1234")

        XCTAssertEqual(keychain.savedValue, "1234")
    }

    func test_validate_whenPinIsCorrect_returnsTrue() throws {
        try sut.save(pin: "1234")

        let result = sut.validate(pin: "1234")

        XCTAssertTrue(result)
    }

    func test_validate_whenPinIsIncorrect_returnsFalse() throws {
        try sut.save(pin: "1234")

        let result = sut.validate(pin: "0000")

        XCTAssertFalse(result)
    }

    func test_removePin_deletesPinFromKeychain() throws {
        try sut.save(pin: "1234")

        sut.removePin()

        XCTAssertTrue(keychain.didCallDelete)
        XCTAssertNil(keychain.savedValue)
    }

    func test_hasPin_whenPinExists_returnsTrue() throws {
        try sut.save(pin: "1234")

        let result = sut.hasPin()

        XCTAssertTrue(result)
    }

    func test_hasPin_whenPinDoesNotExist_returnsFalse() {
        keychain.savedValue = nil

        let result = sut.hasPin()

        XCTAssertFalse(result)
    }

    func test_hasPin_whenPinIsEmpty_returnsFalse() {
        keychain.savedValue = ""

        let result = sut.hasPin()

        XCTAssertFalse(result)
    }
 }
