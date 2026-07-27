//
//  SearchService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 20.04.26.
//

import Foundation
import Storage

final class SearchService {

    typealias ResponseModel = MultiResponseModel

    private let mediaService: MediaServiceProtocol

    init(mediaService: MediaServiceProtocol) {
        self.mediaService = mediaService
    }

    func search(
        query: String,
        page: Int,
        type: SearchType = .multi
    ) async throws -> [any MediaDTODescription] {

        switch type {

        case .multi:
            let data = try await mediaService.search { token in
                TheMovieDBRequest<MultiResponseModel>(
                    apiToken: token,
                    url: URLBuilder.search(type: type, query: query, page: page)
                )
            }

            return data.results.compactMap { $0.toDTO() }

        case .movie:
            let data = try await mediaService.search { token in
                TheMovieDBRequest<MovieResponseModel>(
                    apiToken: token,
                    url: URLBuilder.search(type: type, query: query, page: page)
                )
            }

            return data.results.map { $0.toDTO() }

        case .tv:
            let data = try await mediaService.search { token in
                TheMovieDBRequest<TVResponseModel>(
                    apiToken: token,
                    url: URLBuilder.search(type: type, query: query, page: page)
                )
            }

            return data.results.map { $0.toDTO() }

        case .person:
            let data = try await mediaService.search { token in
                TheMovieDBRequest<PersonResponseModel>(
                    apiToken: token,
                    url: URLBuilder.search(type: type, query: query, page: page)
                )
            }

            return data.results.map { $0.toDTO() }
        }
    }

}
