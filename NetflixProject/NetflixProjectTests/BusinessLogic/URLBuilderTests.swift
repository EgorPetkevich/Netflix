//
//  URLBuilderTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import XCTest
@testable import NetflixProject

final class URLBuilderTests: XCTestCase {

    func test_appendPathAndQueryItem_buildsExpectedURL() throws {
        let url = try XCTUnwrap(
            URLBuilder(environment: TestEnvironment())
                .appendPath("search")
                .appendPath("/movie")
                .appendPath("")
                .addQueryItem(name: "query", value: "inside job")
                .addQueryItem(name: "page", value: "2")
                .build()
        )

        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "example.com")
        XCTAssertEqual(components.path, "/api/search/movie")
        XCTAssertEqual(
            components.queryItems,
            [
                URLQueryItem(name: "query", value: "inside job"),
                URLQueryItem(name: "page", value: "2")
            ]
        )
    }

    func test_movieListURL_containsListTypePageAndLanguage() throws {
        let url = try XCTUnwrap(
            URLBuilder.movie(listType: .topRated, page: 4)
        )
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "api.themoviedb.org")
        XCTAssertEqual(components.path, "/3/movie/top_rated")
        XCTAssertTrue(components.containsQueryItem(name: "language", value: "en-US"))
        XCTAssertTrue(components.containsQueryItem(name: "page", value: "4"))
    }

    func test_tvListURL_containsListTypePageAndLanguage() throws {
        let url = try XCTUnwrap(
            URLBuilder.tv(listType: .airingToday, page: 3)
        )
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.path, "/3/tv/airing_today")
        XCTAssertTrue(components.containsQueryItem(name: "language", value: "en-US"))
        XCTAssertTrue(components.containsQueryItem(name: "page", value: "3"))
    }

    func test_searchURL_containsTypeQueryPageAndLanguage() throws {
        let url = try XCTUnwrap(
            URLBuilder.search(type: .person, query: "Tom Hanks", page: 2)
        )
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.path, "/3/search/person")
        XCTAssertTrue(components.containsQueryItem(name: "query", value: "Tom Hanks"))
        XCTAssertTrue(components.containsQueryItem(name: "page", value: "2"))
        XCTAssertTrue(components.containsQueryItem(name: "language", value: "en-US"))
    }

    func test_imageURL_containsSizeAndPath() throws {
        let url = try XCTUnwrap(
            URLBuilder.image(type: .poster(path: "/poster.jpg"), size: .w780)
        )
        let components = try XCTUnwrap(
            URLComponents(url: url, resolvingAgainstBaseURL: false)
        )

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "image.tmdb.org")
        XCTAssertEqual(components.path, "/t/p/w780/poster.jpg")
        XCTAssertTrue(components.containsQueryItem(name: "language", value: "en-US"))
    }
}

private struct TestEnvironment: APIEnvironment {
    let host = "example.com"
    let scheme = "https"
    let defaultBasePath = "/api"
}

extension URLComponents {
    func containsQueryItem(name: String, value: String) -> Bool {
        queryItems?.contains(URLQueryItem(name: name, value: value)) == true
    }
}
