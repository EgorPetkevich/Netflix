//
//  MovieDetailsStorageSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 22.06.26.
//

import XCTest
@testable import NetflixProject
@testable import Storage

final class MovieDetailsStorageStub: MovieDetailsStorageUseCaseProtocol {

    var result: MovieDTO?

    private(set) var didFetch = false
    private(set) var receivedId: String?

    func fetch(by id: String) async -> MovieDTO? {
        didFetch = true
        receivedId = id

        return result
    }
}
