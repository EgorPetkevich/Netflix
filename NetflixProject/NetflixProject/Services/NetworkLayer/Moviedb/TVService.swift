//
//  TVService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 10.04.26.
//

import Foundation
import Combine
import Storage

final class TVService {

    typealias ResponseModel = TVResponseModel

    private let mediaService: MediaServiceProtocol

    init(mediaService: MediaServiceProtocol) {
        self.mediaService = mediaService
    }

    func fetchAllHomeData() -> AnyPublisher<(TVHomeData), Error> {
        Publishers.Zip4(
            getTVList(type: .airingToday, page: 1),
            getTVList(type: .onTheAir, page: 1),
            getTVList(type: .popular, page: 1),
            getTVList(type: .topRated, page: 1)
        )
        .map { airingToday, onTheAir, popular, topRated in
            TVHomeData(
                airingToday: airingToday,
                onTheAir: onTheAir,
                popular: popular,
                topRated: topRated
            )
        }
        .eraseToAnyPublisher()
    }

    func getTVList(
        type: TVListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {
        return mediaService.getRawList { token in
            TheMovieDBRequest<ResponseModel>(
                apiToken: token,
                url: URLBuilder.tv(listType: type, page: page)
            )
        }
        .map { response in
            response.results.compactMap { $0.toDTO() }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

}
