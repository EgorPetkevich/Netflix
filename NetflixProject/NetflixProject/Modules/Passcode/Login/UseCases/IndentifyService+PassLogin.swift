//
//  Indentify+PassLogin.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 7.05.26.
//

import Foundation

struct PassLoginIndentifyServiceUseCase: PassLoginIndentifyServiceUseCaseProtocol {

    private let service: IdentifyService

    init(service: IdentifyService) {
        self.service = service
    }

    func indentify() async throws {
        try await service.indentify()
    }

}
