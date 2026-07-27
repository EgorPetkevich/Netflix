//
//  MediaServiceTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import Combine
import XCTest
@testable import NetflixProject

final class MediaServiceTests: XCTestCase {

    private var session: MockNetworkSessionProvider!
    private var fetchTokenService: MockFetchTokenService!
    private var sut: MediaService!

    override func setUp() {
        super.setUp()
        session = MockNetworkSessionProvider()
        fetchTokenService = MockFetchTokenService()
        sut = MediaService(
            session: session,
            fetchTokenService: fetchTokenService
        )
    }

    override func tearDown() {
        sut = nil
        fetchTokenService = nil
        session = nil
        super.tearDown()
    }

    func test_search_usesFetchedTokenForRequest() async throws {
        let response = MovieResponseModel(
            dates: nil,
            page: 1,
            results: [],
            totalPages: 1,
            totalResults: 0
        )
        session.asyncResponse = response

        let result: MovieResponseModel = try await sut.search { token in
            TheMovieDBRequest<MovieResponseModel>(
                apiToken: token,
                url: URL(string: "https://example.com/movie")
            )
        }

        XCTAssertEqual(result.page, 1)
        XCTAssertEqual(fetchTokenService.fetchCount, 1)
        XCTAssertEqual(session.sentRequests.count, 1)
        XCTAssertEqual(
            session.sentRequests.first?.value(forHTTPHeaderField: "Authorization"),
            "Bearer fetched-token"
        )
    }

    func test_search_whenCalledTwice_reusesCachedToken() async throws {
        session.asyncResponse = MovieResponseModel(
            dates: nil,
            page: 1,
            results: [],
            totalPages: 1,
            totalResults: 0
        )

        let firstResult: MovieResponseModel = try await sut.search { token in
            TheMovieDBRequest<MovieResponseModel>(
                apiToken: token,
                url: URL(string: "https://example.com/first")
            )
        }
        let secondResult: MovieResponseModel = try await sut.search { token in
            TheMovieDBRequest<MovieResponseModel>(
                apiToken: token,
                url: URL(string: "https://example.com/second")
            )
        }

        XCTAssertEqual(firstResult.page, 1)
        XCTAssertEqual(secondResult.page, 1)
        XCTAssertEqual(fetchTokenService.fetchCount, 1)
        XCTAssertEqual(session.sentRequests.count, 2)
    }

    func test_getRawList_usesFetchedTokenForPublisherRequest() {
        let expectation = expectation(description: "Publisher emits response")
        session.publisherResponse = MovieResponseModel(
            dates: nil,
            page: 2,
            results: [],
            totalPages: 1,
            totalResults: 0
        )

        let cancellable = sut.getRawList { token in
            TheMovieDBRequest<MovieResponseModel>(
                apiToken: token,
                url: URL(string: "https://example.com/list")
            )
        }
        .sink(
            receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    XCTFail("Unexpected publisher failure: \(error)")
                }
            },
            receiveValue: { response in
                XCTAssertEqual(response.page, 2)
                expectation.fulfill()
            }
        )

        wait(for: [expectation], timeout: 1)
        cancellable.cancel()

        XCTAssertEqual(fetchTokenService.fetchCount, 1)
        XCTAssertEqual(
            session.sentRequests.first?.value(forHTTPHeaderField: "Authorization"),
            "Bearer fetched-token"
        )
    }
}

private final class MockNetworkSessionProvider: NetworkSessionProviderProtocol {

    enum MockError: Error {
        case missingResponse
    }

    var asyncResponse: Any?
    var publisherResponse: Any?
    var sentRequests: [URLRequest] = []

    func send<Request: NetworkRequest>(
        request: Request
    ) -> AnyPublisher<Request.ResponseModel, Error> {
        sentRequests.append(request.urlRequest)

        guard let response = publisherResponse as? Request.ResponseModel else {
            return Fail(error: MockError.missingResponse).eraseToAnyPublisher()
        }

        return Just(response)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func send<Request: NetworkRequest>(
        request: Request
    ) async throws -> Request.ResponseModel {
        sentRequests.append(request.urlRequest)

        guard let response = asyncResponse as? Request.ResponseModel else {
            throw MockError.missingResponse
        }

        return response
    }
}

private final class MockFetchTokenService: FetchTokenServiceProtocol {

    var fetchCount = 0

    func fetchToken() async throws -> String {
        fetchCount += 1
        return "fetched-token"
    }
}
