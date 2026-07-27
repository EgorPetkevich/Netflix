//
//  MovieDetails+PurchaseServ.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 22.06.26.
//

import Foundation

struct MovieDetailsPurchesServUseCase: MovieDetailsPurchesServUseCaseProtocol {

    private let service: PurchaseService

    init(service: PurchaseService) {
        self.service = service
    }

    func hasActiveSubscription() async -> Bool {
        await service.hasActiveSubscription()
    }

}
