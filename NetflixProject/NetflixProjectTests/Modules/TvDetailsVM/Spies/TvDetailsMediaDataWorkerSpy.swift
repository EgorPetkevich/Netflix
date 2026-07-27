//
//  TvDetailsMediaDataWorkerSpy.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 23.06.26.
//

import XCTest
@testable import NetflixProject
@testable import Storage

final class TvDetailsMediaDataWorkerSpy: TvDetaisMediaDataWorkerUseCaseProtocol {

    var error: Error?

    private(set) var didUpdateOrDelete = false
    private(set) var updateOrDeleteCallCount = 0
    private(set) var receivedDTO: (any MediaDTODescription)?

    func updateOrDelete(dto: any MediaDTODescription) async throws {
        didUpdateOrDelete = true
        updateOrDeleteCallCount += 1
        receivedDTO = dto

        if let error {
            throw error
        }
    }
}
