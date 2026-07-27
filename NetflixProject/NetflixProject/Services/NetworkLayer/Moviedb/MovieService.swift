//
//  MoviedbService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 9.04.26.
//

import Foundation
import Combine
import Storage

final class MovieService {

    typealias ResponseModel = MovieResponseModel

    private let mediaService: MediaServiceProtocol

    init(mediaService: MediaServiceProtocol) {
        self.mediaService = mediaService
    }

    func fetchAllHomeData() -> AnyPublisher<MoviewHomeData, Error> {
        Publishers.Zip4(
            getMovieList(type: .nowPlaying, page: 1),
            getMovieList(type: .popular, page: 1),
            getMovieList(type: .topRated, page: 1),
            getMovieList(type: .upcoming, page: 1)
        )
        .map { nowPlaying, popular, topRated, upcoming in
            MoviewHomeData(
                nowPlaying: nowPlaying,
                popular: popular,
                topRated: topRated,
                upcoming: upcoming
            )
        }
        .eraseToAnyPublisher()
    }

    func getMovieList(
        type: MovieListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {
        return mediaService.getRawList { token in
            TheMovieDBRequest<ResponseModel>(
                apiToken: token,
                url: URLBuilder.movie(listType: type, page: page)
            )
        }
        .map { response in
            response.results.compactMap { $0.toDTO() }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

}
