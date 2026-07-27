//
//  PersonDTO.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation

public struct PersonDTO: MediaDTODescription {

    public typealias MO = PersonMO

    public var title: String {
        get {
            return self.name
        } set {
            self.name = newValue
        }
    }

    public var voteAverage: Double {
        get {
            popularity ?? 0.0
        } set {
            popularity = newValue
        }

    }

    public var id: String

    public var date: Date
    public var isFavorite: Bool
    public var isBookmarked: Bool

    public var name: String
    public var originalName: String
    public var posterPath: String?
    public var popularity: Double?
    public var gender: Int?
    public var knownForDepartment: String?

    public var overview: String = ""

    public var knownFor: [any MediaDTODescription]

    public init(
        id: String,
        date: Date,
        isFavorite: Bool,
        isBookmarked: Bool,
        name: String,
        originalName: String,
        posterPath: String? = nil,
        popularity: Double? = nil,
        gender: Int? = nil,
        knownForDepartment: String? = nil,
        knownFor: [any MediaDTODescription]
    ) {
        self.id = id
        self.date = date
        self.isFavorite = isFavorite
        self.isBookmarked = isBookmarked
        self.name = name
        self.originalName = originalName
        self.posterPath = posterPath
        self.popularity = popularity
        self.gender = gender
        self.knownForDepartment = knownForDepartment
        self.knownFor = knownFor
    }

    public init(mo: PersonMO) {
        self.id = mo.id
        self.date = mo.date
        self.isFavorite = mo.isFavorite
        self.isBookmarked = mo.isBookmarked
        self.name = mo.name
        self.originalName = mo.originalName
        self.posterPath = mo.posterPath
        self.popularity = mo.popularity
        self.gender = mo.gender
        self.knownForDepartment = mo.knownForDepartment
        self.knownFor = mo.knownForMovies.compactMap { $0.toDTO() } + mo.knownForTvs.compactMap { $0.toDTO() }
    }

    public func createMO() -> PersonMO {
        let person = PersonMO(
            id: id,
            date: date,
            isFavorite: isFavorite,
            isBookmarked: isBookmarked,
            name: name,
            originalName: originalName,
            posterPath: posterPath,
            popularity: popularity,
            gender: gender,
            knownForDepartment: knownForDepartment,
            knownFor: knownFor.compactMap { $0.createMO() }
//            knownFor: []
        )
        return person
    }
}
