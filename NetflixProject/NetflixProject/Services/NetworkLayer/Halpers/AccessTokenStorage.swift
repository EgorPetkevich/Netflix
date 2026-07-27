//
//  AccessTokenStorage.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 13.05.26.
//

import Foundation

actor AccessTokenStorage {

    private var accessToken: String?
    private var tokenTask: Task<String, Error>?

    func getValidToken(
        fetchToken: @escaping @Sendable () async throws -> String
    ) async throws -> String {
        if let accessToken {
            return accessToken
        }

        if let tokenTask {
            return try await tokenTask.value
        }

        let task = Task {
            try await fetchToken()
        }

        tokenTask = task

        do {
            let token = try await task.value
            accessToken = token
            tokenTask = nil
            return token
        } catch {
            tokenTask = nil
            throw error
        }
    }
}
