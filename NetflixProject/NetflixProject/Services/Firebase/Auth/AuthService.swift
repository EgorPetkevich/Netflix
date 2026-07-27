//
//  AuthService.swift
//  NetflixProject
//
//  Created by George Popkich on 31.03.26.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Combine

protocol AuthServiceProtocol {
    func signIn(email: String, password: String) async throws
    func resetPassword(email: String) async throws
    func singUp(email: String, password: String) async throws
    func signInGuest() async throws
    func signOut() throws

    var currentUserEmail: String? { get }
    var currentUserName: String? { get }
    var currentUserID: String? { get }
}

final class AuthService: AuthServiceProtocol {

    private var auth: Auth {
        Auth.auth()
    }

    @MainActor
    static func signInWithGoogle(
        viewController: UIViewController
    ) async throws {

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError()
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: viewController
        )

        guard let idToken = result.user.idToken?.tokenString else {
            throw NSError()
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        try await Auth.auth().signIn(with: credential)
    }

    func signIn(email: String, password: String) async throws {
        let credential = EmailAuthProvider.credential(
            withEmail: email,
            password: password
        )

        try await auth.signIn(with: credential)
    }

    func resetPassword(email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }

    func singUp(email: String, password: String) async throws {
        try await auth.createUser(withEmail: email, password: password)
    }

    func signInGuest() async throws {
        try await auth.signInAnonymously()
    }

    func signOut() throws {
        try auth.signOut()
    }

    var currentUserEmail: String? {
        auth.currentUser?.email
    }

    var currentUserName: String? {
        auth.currentUser?.displayName
    }

    var currentUserID: String? {
        auth.currentUser?.uid
    }

}
