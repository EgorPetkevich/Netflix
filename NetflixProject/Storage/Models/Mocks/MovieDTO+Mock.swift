//
//  MovieDTO+Mock.swift
//  Storage
//
//  Created by Egor Petkevich on 1.07.26.
//

import Foundation

public extension MovieDTO {

    public static func mock(
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
