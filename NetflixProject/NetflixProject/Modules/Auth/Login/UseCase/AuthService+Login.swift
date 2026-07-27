//
//  AuthService+Login.swift
//  NetflixProject
//
//  Created by George Popkich on 31.03.26.
//

import Foundation
import RxSwift

struct LoginAuthServiceUseCase: LoginAuthServiceUseCaseProtocol {

    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    func signIn(email: String, password: String) -> Completable {
        return Completable.create { completable in
            let task = Task {
                do {
                    try await service.signIn(email: email, password: password)
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            return Disposables.create { task.cancel() }
        }
    }

    func signAsGuest() -> Completable {
        return Completable.create { completable in
            let task = Task {
                do {
                    try await service.signInGuest()
                    return completable(.completed)
                } catch {
                    return completable(.error(error))
                }
            }
            return Disposables.create { task.cancel() }
        }
    }

}
