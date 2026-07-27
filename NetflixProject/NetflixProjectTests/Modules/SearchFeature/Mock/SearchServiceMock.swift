//
//  SearchServiceMock.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 24.06.26.
//

import XCTest
@testable import NetflixProject
@testable import Storage

final class SearchServiceMock: SearchServiceUseCaseProtocol {

    var searchHandler: (
        _ query: String,
        _ page: Int,
        _ type: SearchType
    ) async throws -> [any MediaDTODescription] = { _, _, _ in
        []
    }

    func search(
        query: String,
        page: Int,
        type: SearchType
    ) async throws -> [any MediaDTODescription] {
        try await searchHandler(query, page, type)
    }
}
