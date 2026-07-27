//
//  AuthServiceMock.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 30.06.26.
//

import XCTest
@testable import NetflixProject

final class AuthServiceMock: AuthServiceProtocol {

    var currentUserEmailResult: String?
    var currentUserNameResult: String?
    var currentUserIDResult: String?

    var signInHandler: ((String, String) async throws -> Void)?
    var resetPasswordHandler: ((String) async throws -> Void)?
    var singUpHandler: ((String, String) async throws -> Void)?
    var signInGuestHandler: (() async throws -> Void)?
    var signOutHandler: (() throws -> Void)?

    var currentUserEmail: String? {
        currentUserEmailResult
    }

    var currentUserName: String? {
        currentUserNameResult
    }

    var currentUserID: String? {
        currentUserIDResult
    }

    func signIn(email: String, password: String) async throws {
        try await signInHandler?(email, password)
    }

    func resetPassword(email: String) async throws {
        try await resetPasswordHandler?(email)
    }

    func singUp(email: String, password: String) async throws {
        try await singUpHandler?(email, password)
    }

    func signInGuest() async throws {
        try await signInGuestHandler?()
    }

    func signOut() throws {
        try signOutHandler?()
    }
}
