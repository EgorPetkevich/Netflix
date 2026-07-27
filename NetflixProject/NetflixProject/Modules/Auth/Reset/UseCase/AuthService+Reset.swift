//
//  AuthService+Reset.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation
import Combine

struct ResetAuthServiceUseCase: ResetAuthServiceUseCaseProtocol {

    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { result in
            Task {
                do {
                    try await service.resetPassword(email: email)
                    result(.success(()))
                } catch {
                    result(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }

}
