//
//  MediaSectionType.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 10.04.26.
//

import Foundation

enum MediaSectionType {
    case movie(MovieSection)
    case tv(TVSection)

    enum MovieSection {
        case nowPlaying, popular, upcoming, topRated
    }

    enum TVSection {
        case airing, onAir, popular, topRated
    }
}

extension MediaSectionType {

    var title: String {
        switch self {
        case .movie(let section):
            switch section {
            case .nowPlaying: return "Now Playing"
            case .popular:    return "Popular Movies"
            case .upcoming:   return "Upcoming"
            case .topRated:   return "Top Rated Movies"
            }
        case .tv(let section):
            switch section {
            case .airing:   return "Airing Today"
            case .onAir:    return "On The Air"
            case .popular:  return "Popular TV's"
            case .topRated: return "Top Rated TV's"
            }
        }
    }

    var movieServiceType: MovieListType? {
        guard case .movie(let section) = self else { return nil }
        switch section {
        case .nowPlaying: return .nowPlaying
        case .popular:    return .popular
        case .upcoming:   return .upcoming
        case .topRated:   return .topRated
        }
    }

    var tvServiceType: TVListType? {
        guard case .tv(let section) = self else { return nil }
        switch section {
        case .airing:   return .airingToday
        case .onAir:    return .onTheAir
        case .popular:  return .popular
        case .topRated: return .topRated
        }
    }
}

extension MediaSectionType: Hashable {}
extension MediaSectionType.MovieSection: Hashable {}
extension MediaSectionType.TVSection: Hashable {}
