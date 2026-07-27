//
//  MediaService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 10.04.26.
//

import Foundation
import Combine

protocol MediaServiceProtocol {
    func getRawList<Request: NetworkRequest>(
        with requestBuilder: @escaping (String) -> Request
    ) -> AnyPublisher<Request.ResponseModel, Error>

    func search<Request: NetworkRequest>(
        with requestBuilder: (String) async -> Request
    ) async throws -> Request.ResponseModel
}

final class MediaService: MediaServiceProtocol {

    private let accessTokenStorage = AccessTokenStorage()

    private let session: NetworkSessionProviderProtocol
    private let fetchTokenService: FetchTokenServiceProtocol

    init(
        session: NetworkSessionProviderProtocol,
        fetchTokenService: FetchTokenServiceProtocol
    ) {
        self.session = session
        self.fetchTokenService = fetchTokenService
    }

    private func getValidToken() async throws -> String {
        try await accessTokenStorage.getValidToken { [fetchTokenService] in
            try await fetchTokenService.fetchToken()
        }
    }

    func search<Request: NetworkRequest>(
        with requestBuilder: (String) async -> Request
    ) async throws -> Request.ResponseModel {

        let token = try await getValidToken()

        let request = await requestBuilder(token)

        return try await session.send(request: request)
    }

    func getRawList<Request: NetworkRequest>(
        with requestBuilder: @escaping (String) -> Request
    ) -> AnyPublisher<Request.ResponseModel, Error> {

        return Deferred {
            Future { [weak self] promise in
                Task {
                    guard let self = self else { return }
                    do {
                        let token = try await self.getValidToken()
                        promise(.success(token))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .flatMap { [weak self] token -> AnyPublisher<Request.ResponseModel, Error> in
            guard let self = self else {
                return Fail(error: URLError(.badServerResponse)).eraseToAnyPublisher()
            }

            return self.session.send(request: requestBuilder(token))
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

}
