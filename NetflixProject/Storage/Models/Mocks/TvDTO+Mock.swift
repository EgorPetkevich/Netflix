//
//  TvDTO+Mock.swift
//  Storage
//
//  Created by Egor Petkevich on 1.07.26.
//

import Foundation

public extension TvDTO {

    public static func mock(
        id: String = "1",
        date: Date = Date(timeIntervalSince1970: 0),
        isFavorite: Bool = false,
        isBookmarked: Bool = false,
        isSubscribed: Bool = false,
        name: String = "Test TV",
        originalName: String = "Test Original Tv",
        overview: String = "Test overview",
        popularity: Double = 10.0,
        voteAverage: Double = 7.5,
        voteCount: Int = 100
    ) -> TvDTO {
        TvDTO(
            id: id,
            date: date,
            isFavorite: isFavorite,
            isBookmarked: isBookmarked,
            name: name,
            originalName: originalName,
            overview: overview,
            popularity: popularity,
            voteAverage: voteAverage,
            voteCount: voteCount
        )
    }
}
