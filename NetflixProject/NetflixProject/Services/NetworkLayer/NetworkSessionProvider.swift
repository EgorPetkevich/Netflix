//
//  NetworkSessionProvider.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 9.04.26.
//

import UIKit
import Combine

enum NetworkSessionError: Error {
    case invalidUrl
    case invalidImageData
}

protocol NetworkSessionProviderProtocol {
    func send<Request: NetworkRequest>(
        request: Request
    ) -> AnyPublisher<Request.ResponseModel, Error>

    func send<Request: NetworkRequest>(
        request: Request
    ) async throws -> Request.ResponseModel
}

final class NetworkSessionProvider: NetworkSessionProviderProtocol {

    private let logger: Logger = Logger(NetworkSessionProvider.self)

    func send<Request: NetworkRequest>(
        request: Request
    ) -> AnyPublisher<Request.ResponseModel, Error> {

        return URLSession.shared.dataTaskPublisher(for: request.urlRequest)
            .tryMap { element in
                guard let response = element.response as? HTTPURLResponse,
                      (200...299).contains(response.statusCode) else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: Request.ResponseModel.self, decoder: JSONDecoder())
            .map { $0 }
            .mapError { error -> Error in
                if let decodingError = error as? DecodingError {
                    self.logger.error("Decoding error: \(decodingError)")
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    func send<Request: NetworkRequest>(
        request: Request
    ) async throws -> Request.ResponseModel {

        let (data, response) = try await URLSession.shared.data(
            for: request.urlRequest
        )

        guard let response = response as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }

        do {
            let decoded = try JSONDecoder().decode(
                Request.ResponseModel.self, from: data
            )
            return decoded
        } catch {
            throw error
        }
    }

}
