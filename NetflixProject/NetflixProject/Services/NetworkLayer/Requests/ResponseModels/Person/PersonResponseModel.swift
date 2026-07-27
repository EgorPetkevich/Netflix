//
//  PersonResponseModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation

struct PersonResponseModel: Decodable {
    let page: Int
    let results: [Person]
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page, results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}

struct Person: Decodable, Equatable, Hashable {
    let id: Int
    let name: String
    let originalName: String
    let profilePath: String?
    let popularity: Double?
    let gender: Int?
    let knownForDepartment: String?
    let knownFor: [KnownFor]?

    enum CodingKeys: String, CodingKey {
        case id, name, popularity, gender
        case originalName = "original_name"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
        case knownFor = "known_for"
    }
}

enum KnownFor: Decodable, Equatable, Hashable {
    case movie(Movie)
    case tv(TV)

    private enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
    }

    private enum MediaType: String, Decodable {
        case movie, tv
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MediaType.self, forKey: .mediaType)

        switch type {
        case .movie:
            self = .movie(try Movie(from: decoder))
        case .tv:
            self = .tv(try TV(from: decoder))
        }
    }
}
