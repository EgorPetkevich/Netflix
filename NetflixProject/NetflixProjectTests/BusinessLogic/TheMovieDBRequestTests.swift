//
//  TheMovieDBRequestTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import XCTest
@testable import NetflixProject

final class TheMovieDBRequestTests: XCTestCase {

    func test_urlRequest_containsMethodHeadersAndBody() throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/3/movie"))
        let request = TheMovieDBRequest<EmptyResponse>(
            apiToken: "test-token",
            url: url
        )

        let urlRequest = request.urlRequest

        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, "GET")
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "accept"),
            "application/json"
        )
        XCTAssertEqual(
            urlRequest.value(forHTTPHeaderField: "Authorization"),
            "Bearer test-token"
        )
        XCTAssertNil(urlRequest.httpBody)
    }
}

private struct EmptyResponse: Decodable {}
