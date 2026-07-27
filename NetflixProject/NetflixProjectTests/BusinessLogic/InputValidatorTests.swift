//
//  InputValidatorTests.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import XCTest
@testable import NetflixProject

final class InputValidatorTests: XCTestCase {

    private var sut: InputValidator!

    override func setUp() {
        super.setUp()
        self.sut = InputValidator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_validEmail_returnsTrue() {
        let sut = InputValidator()
        let validEmail = "test_email@test.test"

        let result = sut.isValid(email: validEmail)

        XCTAssertTrue(result)
    }

    func test_invalidEmail_returnsFalse() {
        let sut = InputValidator()
        let invalidEmail = "test_email"

        let result = sut.isValid(email: invalidEmail)

        XCTAssertFalse(result)
    }

    func test_validPassword_returnsTrue() {
        let sut = InputValidator()
        let validPassword = "!Ttest1234567"

        let result = sut.isValid(password: validPassword)

        XCTAssertTrue(result)
    }

    func test_invalidPassword_returnsFalse() {
        let sut = InputValidator()
        let invalidPassword = "123"

        let result = sut.isValid(password: invalidPassword)

        XCTAssertFalse(result)
    }
}
