//
//  MultiResponseModel.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation

enum MediaType: String, Decodable {
    case movie, tv, person
}

struct MultiResponseModel: Decodable {

    let page: Int

    let results: [MultiResult]

    enum CodingKeys: String, CodingKey {
        case page, results
    }

}

enum MultiResult: Decodable {
    case movie(Movie)
    case tv(TV)
    case person(Person)

    private enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MediaType.self, forKey: .mediaType)

        switch type {
        case .movie:
            self = .movie(try Movie(from: decoder))
        case .tv:
            self = .tv(try TV(from: decoder))
        case .person:
            self = .person(try Person(from: decoder))
        }
    }
}
