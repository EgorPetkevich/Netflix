//
//  TvDetailsStorageStub.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 23.06.26.
//

import XCTest
@testable import NetflixProject
@testable import Storage

final class TvDetailsStorageStub: TvDetailsAllMediaStorageUseCaseProtocol {

    var result: (any MediaDTODescription)?

    private(set) var didFetch = false
    private(set) var receivedId: String?

    func fetch(by id: String) async -> (any MediaDTODescription)? {
        didFetch = true
        receivedId = id

        return result
    }
}
