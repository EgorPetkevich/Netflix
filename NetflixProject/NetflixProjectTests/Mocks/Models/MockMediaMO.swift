//
//  MockMediaMO.swift
//  NetflixProjectTests
//
//  Created by Egor Petkevich on 16.06.26.
//

import Foundation
import SwiftData
@testable import Storage

@Model
final class MockMediaMO: MediaMODescription {

    var id: String
    var date: Date
    var title: String
    var posterPath: String?
    var voteAverage: Double
    var overview: String
    var isFavorite: Bool
    var isBookmarked: Bool

    init(
        id: String,
        date: Date,
        title: String,
        posterPath: String?,
        voteAverage: Double,
        overview: String,
        isFavorite: Bool,
        isBookmarked: Bool
    ) {
        self.id = id
        self.date = date
        self.title = title
        self.posterPath = posterPath
        self.voteAverage = voteAverage
        self.overview = overview
        self.isFavorite = isFavorite
        self.isBookmarked = isBookmarked
    }

    convenience init(dto: MockMediaDTO) {
        self.init(
            id: dto.id,
            date: dto.date,
            title: dto.title,
            posterPath: dto.posterPath,
            voteAverage: dto.voteAverage,
            overview: dto.overview,
            isFavorite: dto.isFavorite,
            isBookmarked: dto.isBookmarked
        )
    }

    func apply(dto: any MediaDTODescription) {
        id = dto.id
        date = dto.date
        title = dto.title
        posterPath = dto.posterPath
        voteAverage = dto.voteAverage
        overview = dto.overview
        isFavorite = dto.isFavorite
        isBookmarked = dto.isBookmarked
    }

    func toDTO() -> (any MediaDTODescription)? {
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
