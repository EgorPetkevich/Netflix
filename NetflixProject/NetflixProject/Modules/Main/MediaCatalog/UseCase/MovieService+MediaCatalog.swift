//
//  MovieService+MediaCatalog.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 15.04.26.
//

import Foundation
import Combine
import Storage

struct MediaCatalogMovieServiceUseCase: MediaCatalogMovieServiceUseCaseProtocol {

    private let service: MovieService

    init(service: MovieService) {
        self.service = service
    }

    func getMovieList(
        type: MovieListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {
        return service.getMovieList(type: type, page: page)
    }

}
