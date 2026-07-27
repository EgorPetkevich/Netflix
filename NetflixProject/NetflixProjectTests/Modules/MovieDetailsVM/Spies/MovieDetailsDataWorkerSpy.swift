//
//  MovieDetailsDataWorkerSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 22.06.26.
//

import XCTest
@testable import NetflixProject
@testable import Storage

final class MovieDetailsMediaDataWorkerSpy: MovieDetaisMediaDataWorkerUseCaseProtocol {

    var error: Error?

    private(set) var didUpdateOrDelete = false
    private(set) var updateOrDeleteCallCount = 0
    private(set) var receivedDTO: MovieDTO?

    func updateOrDelete(dto: MovieDTO) async throws {
        didUpdateOrDelete = true
        updateOrDeleteCallCount += 1
        receivedDTO = dto

        if let error {
            throw error
        }
    }
}
