//
//  TVService+MediaCatalog.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import Foundation
import Combine
import Storage

struct MediaCatalogTVServiceUseCase: MediaCatalogTVServiceUseCaseProtocol {

    private let service: TVService

    init(service: TVService) {
        self.service = service
    }

    func getTVList(
        type: TVListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {
        return service.getTVList(type: type, page: page)
    }

}
