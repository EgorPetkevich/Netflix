//
//  MockMovieDTO.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
@testable import Storage

extension MovieDTO {

    static func mock(
        id: String = "1",
        date: Date = Date(timeIntervalSince1970: 0),
        isFavorite: Bool = false,
        isBookmarked: Bool = false,
        isSubscribed: Bool = false,
        title: String = "Test Movie",
        originalTitle: String = "Test Original Movie",
        overview: String = "Test overview",
        releaseDate: String? = nil,
        adult: Bool = false,
        popularity: Double = 10.0,
        voteAverage: Double = 7.5,
        voteCount: Int = 100
    ) -> MovieDTO {
        MovieDTO(
            id: id,
            date: date,
            isFavorite: isFavorite,
            isBookmarked: isBookmarked,
            isSubscribed: isSubscribed,
            title: title,
            originalTitle: originalTitle,
            overview: overview,
            releaseDate: releaseDate,
            adult: adult,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
}
