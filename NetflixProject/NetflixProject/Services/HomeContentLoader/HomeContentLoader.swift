//
//  HomeContentLoader.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 18.05.26.
//

import Foundation
import Combine
import Storage

protocol HomeContentLoaderProtocol {
    var state: AnyPublisher<HomeLoadingState, Never> { get }

    func loadHomeContent() -> AnyPublisher<[MediaListSection], Error>

    func loadNextPage(
        for type: MediaSectionType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error>
}

protocol HomeMovieServiceUseCaseProtocol {
    func fetchAllHomeData() -> AnyPublisher<MoviewHomeData, Error>

    func getMovieList(
        type: MovieListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error>
}

protocol HomeTVServiceUseCaseProtocol {
    func fetchAllHomeData() -> AnyPublisher<TVHomeData, Error>

    func getTVList(
        type: TVListType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error>
}

final class HomeContentLoader: HomeContentLoaderProtocol {

    @CurrentValue(value: .idle)
    var state: AnyPublisher<HomeLoadingState, Never>

    private let movieService: HomeMovieServiceUseCaseProtocol
    private let tvService: HomeTVServiceUseCaseProtocol

    init(
        movieService: HomeMovieServiceUseCaseProtocol,
        tvService: HomeTVServiceUseCaseProtocol
    ) {
        self.movieService = movieService
        self.tvService = tvService
    }

    func loadNextPage(
        for type: MediaSectionType,
        page: Int
    ) -> AnyPublisher<[any MediaDTODescription], Error> {
        if let movieType = type.movieServiceType {
            return movieService.getMovieList(type: movieType, page: page)
        }

        if let tvType = type.tvServiceType {
            return tvService.getTVList(type: tvType, page: page)
        }

        return Fail(error: URLError(.badURL))
            .eraseToAnyPublisher()
    }

    func loadHomeContent() -> AnyPublisher<[MediaListSection], Error> {
        _state.combine.send(.loading)

        return Publishers.Zip(
            movieService.fetchAllHomeData(),
            tvService.fetchAllHomeData()
        )
        .tryMap { movies, tv in
            let sections = Self.combineFirstPage(movies: movies, tv: tv)

            guard sections.contains(where: { !$0.media.isEmpty }) else {
                throw HomeLoaderError.emptyContent
            }

            return sections
        }
        .handleEvents(
            receiveOutput: { [weak self] _ in
                self?._state.combine.send(.ready)
            },
            receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?._state.combine.send(.failed(error.localizedDescription))
                }
            }
        )
        .eraseToAnyPublisher()
    }

    private static func combineFirstPage(
        movies: MoviewHomeData,
        tv: TVHomeData
    ) -> [MediaListSection] {
        [
            MediaListSection(type: .movie(.nowPlaying), media: movies.nowPlaying),
            MediaListSection(type: .tv(.airing), media: tv.airingToday),
            MediaListSection(type: .movie(.popular), media: movies.popular),
            MediaListSection(type: .tv(.popular), media: tv.popular),
            MediaListSection(type: .movie(.topRated), media: movies.topRated),
            MediaListSection(type: .tv(.topRated), media: tv.topRated),
            MediaListSection(type: .movie(.upcoming), media: movies.upcoming),
            MediaListSection(type: .tv(.onAir), media: tv.onTheAir)
        ]
    }
}
