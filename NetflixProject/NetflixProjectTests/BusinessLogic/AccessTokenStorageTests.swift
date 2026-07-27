//
//  AccessTokenStorageTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import XCTest
@testable import NetflixProject

final class AccessTokenStorageTests: XCTestCase {

    private var sut: AccessTokenStorage!

    override func setUp() {
        super.setUp()
        sut = AccessTokenStorage()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_getValidToken_whenTokenFetched_cachesToken() async throws {
        let fetcher = TokenFetcher(results: [.success("cached-token")])

        let firstToken = try await sut.getValidToken {
            try await fetcher.fetch()
        }
        let secondToken = try await sut.getValidToken {
            try await fetcher.fetch()
        }

        let callCount = await fetcher.callCount
        XCTAssertEqual(firstToken, "cached-token")
        XCTAssertEqual(secondToken, "cached-token")
        XCTAssertEqual(callCount, 1)
    }

    func test_getValidToken_whenCalledConcurrently_reusesInFlightTask() async throws {
        let fetcher = TokenFetcher(
            results: [.success("shared-token")],
            delay: 50_000_000
        )

        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<5 {
                group.addTask { [sut] in
                    guard let sut else { return "" }
                    return try await sut.getValidToken {
                        try await fetcher.fetch()
                    }
                }
            }

            var tokens: [String] = []
            for try await token in group {
                tokens.append(token)
            }
            return tokens
        }

        let callCount = await fetcher.callCount
        XCTAssertEqual(tokens, Array(repeating: "shared-token", count: 5))
        XCTAssertEqual(callCount, 1)
    }

    func test_getValidToken_whenFetchFails_allowsRetry() async throws {
        let fetcher = TokenFetcher(
            results: [
                .failure(TokenFetcher.FetchError.failed),
                .success("retry-token")
            ]
        )

        do {
            _ = try await sut.getValidToken {
                try await fetcher.fetch()
            }
            XCTFail("Expected token fetch to fail")
        } catch {
            XCTAssertEqual(error as? TokenFetcher.FetchError, .failed)
        }

        let token = try await sut.getValidToken {
            try await fetcher.fetch()
        }
        let callCount = await fetcher.callCount

        XCTAssertEqual(token, "retry-token")
        XCTAssertEqual(callCount, 2)
    }
}

private actor TokenFetcher {

    enum FetchError: Error {
        case failed
    }

    private var results: [Result<String, Error>]
    private let delay: UInt64

    private(set) var callCount = 0

    init(results: [Result<String, Error>], delay: UInt64 = 0) {
        self.results = results
        self.delay = delay
    }

    func fetch() async throws -> String {
        callCount += 1

        if delay > 0 {
            try await Task.sleep(nanoseconds: delay)
        }

        guard !results.isEmpty else {
            throw FetchError.failed
        }

        return try results.removeFirst().get()
    }
}
