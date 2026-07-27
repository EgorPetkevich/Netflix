//
//  SearchServiceTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import Combine
import XCTest
@testable import NetflixProject
@testable import Storage

final class SearchServiceTests: XCTestCase {

    private var mediaService: MockSearchMediaService!
    private var sut: SearchService!

    override func setUp() {
        super.setUp()
        mediaService = MockSearchMediaService()
        sut = SearchService(mediaService: mediaService)
    }

    override func tearDown() {
        sut = nil
        mediaService = nil
        super.tearDown()
    }

    func test_searchMovie_returnsDTOsAndBuildsMovieSearchRequest() async throws {
        mediaService.response = MovieResponseModel(
            dates: nil,
            page: 1,
            results: [Self.makeMovie(id: 7, title: "Seven")],
            totalPages: 1,
            totalResults: 1
        )

        let result = try await sut.search(
            query: "Seven",
            page: 3,
            type: .movie
        )

        let movie = try XCTUnwrap(result.first as? MovieDTO)
        let components = try XCTUnwrap(
            URLComponents(
                url: try XCTUnwrap(mediaService.capturedURLs.first),
                resolvingAgainstBaseURL: false
            )
        )

        XCTAssertEqual(movie.id, "7")
        XCTAssertEqual(movie.title, "Seven")
        XCTAssertEqual(components.path, "/3/search/movie")
        XCTAssertTrue(components.containsQueryItem(name: "query", value: "Seven"))
        XCTAssertTrue(components.containsQueryItem(name: "page", value: "3"))
        XCTAssertEqual(
            mediaService.capturedHeaders.first?["Authorization"],
            "Bearer test-token"
        )
    }

    func test_searchMulti_returnsMixedDTOs() async throws {
        mediaService.response = MultiResponseModel(
            page: 1,
            results: [
                .movie(Self.makeMovie(id: 1, title: "Movie")),
                .tv(Self.makeTV(id: 2, name: "Show")),
                .person(Self.makePerson(id: 3, name: "Person"))
            ]
        )

        let result = try await sut.search(query: "query", page: 1)

        XCTAssertEqual(result.count, 3)
        XCTAssertTrue(result[0] is MovieDTO)
        XCTAssertTrue(result[1] is TvDTO)
        XCTAssertTrue(result[2] is PersonDTO)
        XCTAssertEqual(result.map(\.id), ["1", "2", "3"])
    }
}

private extension SearchServiceTests {
    static func makeMovie(id: Int, title: String) -> Movie {
        Movie(
            id: id,
            title: title,
            originalTitle: title,
            overview: "Overview",
            posterPath: "/poster.jpg",
            backdropPath: nil,
            releaseDate: "2026-06-17",
            adult: false,
            genreIds: nil,
            originalLanguage: "en",
            popularity: 10,
            video: false,
            voteAverage: 8,
            voteCount: 100
        )
    }

    static func makeTV(id: Int, name: String) -> TV {
        TV(
            id: id,
            name: name,
            originalName: name,
            overview: "Overview",
            posterPath: "/poster.jpg",
            backdropPath: nil,
            firstAirDate: "2026-06-17",
            genreIds: nil,
            originCountry: ["US"],
            originalLanguage: "en",
            popularity: 10,
            voteAverage: 8,
            voteCount: 100
        )
    }

    static func makePerson(id: Int, name: String) -> Person {
        Person(
            id: id,
            name: name,
            originalName: name,
            profilePath: "/profile.jpg",
            popularity: 10,
            gender: 1,
            knownForDepartment: "Acting",
            knownFor: nil
        )
    }
}

private final class MockSearchMediaService: MediaServiceProtocol {

    enum MockError: Error {
        case missingResponse
    }

    var response: Any?
    var capturedURLs: [URL] = []
    var capturedHeaders: [[String: String]] = []

    func getRawList<Request: NetworkRequest>(
        with requestBuilder: @escaping (String) -> Request
    ) -> AnyPublisher<Request.ResponseModel, Error> {
        let request = requestBuilder("test-token")
        if let url = request.url {
            capturedURLs.append(url)
        }
        capturedHeaders.append(request.headers)

        guard let response = response as? Request.ResponseModel else {
            return Fail(error: MockError.missingResponse).eraseToAnyPublisher()
        }

        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func search<Request: NetworkRequest>(
        with requestBuilder: (String) async -> Request
    ) async throws -> Request.ResponseModel {
        let request = await requestBuilder("test-token")
        if let url = request.url {
            capturedURLs.append(url)
        }
        capturedHeaders.append(request.headers)

        guard let response = response as? Request.ResponseModel else {
            throw MockError.missingResponse
        }

        return response
    }
}
