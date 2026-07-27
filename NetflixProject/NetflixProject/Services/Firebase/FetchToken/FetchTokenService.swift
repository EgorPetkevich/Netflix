//
//  FetchTokenService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 9.04.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol FetchTokenServiceProtocol {
    func fetchToken() async throws -> String
}

final class FetchTokenService: FetchTokenServiceProtocol {

    private enum Path: String {
        case collection = "Moviedb"
        case document = "Bearer"
    }

    private var firestore: Firestore {
        return Firestore.firestore()
    }

    private let keychainManager: KeychainManaging
    private let logger: Logger = Logger(FetchTokenService.self)

    init(keychainManager: KeychainManaging) {
        self.keychainManager = keychainManager
    }

    func fetchToken() async throws -> String {

        if let cachedToken = keychainManager.get(.barrierKey) {
            return cachedToken
        }

        guard (Auth.auth().currentUser?.uid) != nil else {
            logger.error("No user is logged in. Request will be rejected by Security Rules.")
            throw FetchTokenError.noUser
        }

        do {
            let snapshot = try await firestore
                .collection(Path.collection.rawValue)
                .document(Path.document.rawValue)
                .getDocument()

            guard snapshot.exists else {
                logger.error("Document not found at path: \(Path.collection.rawValue)/\(Path.document.rawValue)")
                throw FetchTokenError.documentNotFound
            }

            guard
                let data = snapshot.data(),
                let token = data["token"] as? String,
                !token.isEmpty
            else {
                logger.error("Field 'token' is missing, empty or not a String in document.")
                throw FetchTokenError.tokenMissing
            }

            try keychainManager.save(token, usage: .barrierKey)

            logger.success(" Token successfully retrieved.")

            return token

        } catch {
            logger.error("Firestore error: \(error.localizedDescription)")
            throw error
        }
    }
}
