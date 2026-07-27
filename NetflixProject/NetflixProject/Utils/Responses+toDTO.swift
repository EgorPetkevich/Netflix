//
//  Responses+MediaModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation
import Storage

extension Movie {
    func toDTO() -> any MediaDTODescription {
        MovieDTO(
            id: "\(self.id)",
            date: .now,
            isFavorite: false,
            isBookmarked: false,
            isSubscribed: false,
            title: self.title,
            originalTitle: self.originalTitle,
            overview: self.overview,
            posterPath: self.posterPath,
            backdropPath: self.backdropPath,
            releaseDate: self.releaseDate,
            adult: self.adult,
            popularity: self.popularity,
            voteAverage: self.voteAverage,
            voteCount: self.voteCount
        )
    }
}

extension TV {
    func toDTO() -> any MediaDTODescription {
        TvDTO(
            id: "\(self.id)",
            date: .now,
            isFavorite: false,
            isBookmarked: false,
            name: self.name,
            originalName: self.originalName,
            overview: self.overview,
            posterPath: self.posterPath,
            backdropPath: self.backdropPath,
            firstAirDate: self.firstAirDate,
            originCountry: self.originCountry,
            popularity: self.popularity,
            voteAverage: self.voteAverage,
            voteCount: self.voteCount
        )
    }
}

extension Person {
    func toDTO() -> any MediaDTODescription {
        PersonDTO(
            id: "\(self.id)",
            date: .now,
            isFavorite: false,
            isBookmarked: false,
            name: self.name,
            originalName: self.originalName,
            posterPath: self.profilePath,
            popularity: self.popularity,
            gender: self.gender,
            knownForDepartment: self.knownForDepartment,
            knownFor: self.knownFor?.compactMap { $0.toDTO() } ?? []
        )
    }
}

extension MultiResult {
    func toDTO() -> (any MediaDTODescription)? {
        switch self {
        case .movie(let movie):
            return movie.toDTO()
        case .tv(let tv):
            return tv.toDTO()
        case .person(let person):
            return person.toDTO()
        }
    }
}

extension KnownFor {
    func toDTO() -> any MediaDTODescription {
        switch self {
        case .movie(let movie):
            return movie.toDTO()

        case .tv(let tv):
            return tv.toDTO()
        }
    }
}
