//
//  TvDetails+PurchaseServ.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 23.06.26.
//

import Foundation

struct TvDetailsPurchesServUseCase: TvDetailsPurchesServUseCaseProtocol {

    private let service: PurchaseService

    init(service: PurchaseService) {
        self.service = service
    }

    func hasActiveSubscription() async -> Bool {
        await service.hasActiveSubscription()
    }

}
