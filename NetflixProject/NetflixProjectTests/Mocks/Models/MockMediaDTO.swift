//
//  MockMediaDTO.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
@testable import Storage

struct MockMediaDTO: MediaDTODescription {
    typealias MO = MockMediaMO

    var id: String
    var date: Date
    var title: String
    var posterPath: String?
    var voteAverage: Double
    var overview: String
    var isFavorite: Bool
    var isBookmarked: Bool

    func createMO() -> MockMediaMO {
        MockMediaMO(dto: self)
    }
}

extension MockMediaDTO {

    static func make(
        id: String = "1",
        date: Date = Date(timeIntervalSince1970: 0),
        title: String = "Mock title",
        posterPath: String? = nil,
        voteAverage: Double = 7.0,
        overview: String = "Mock overview",
        isFavorite: Bool = true,
        isBookmarked: Bool = false
    ) -> MockMediaDTO {
        MockMediaDTO(
            id: id,
            date: date,
            title: title,
            posterPath: posterPath,
            voteAverage: voteAverage,
            overview: overview,
            isFavorite: isFavorite,
            isBookmarked: isBookmarked
        )
    }
}
