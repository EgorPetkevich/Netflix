//
//  URLBuilder.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 14.04.26.
//

import Foundation

protocol APIEnvironment {
    var host: String { get }

    var scheme: String { get }

    var defaultBasePath: String { get }
}

enum SearchType: String, CaseIterable, Equatable {
    case multi
    case movie
    case tv
    case person

    var displayName: String {
        switch self {
        case .multi: return "All"
        case .movie: return "Movies"
        case .tv: return "TV Shows"
        case .person: return "People"
        }
    }
}

final class URLBuilder {

    private var components = URLComponents()

    init(environment: APIEnvironment) {
        self.components.scheme = environment.scheme
        self.components.host = environment.host
        self.components.path = environment.defaultBasePath
    }

    @discardableResult
    func appendPath(_ path: String) -> URLBuilder {
        guard !path.isEmpty else { return self }
        let currentPath = components.path
        let newPath = path.hasPrefix("/") ? path : "/\(path)"

        components.path = (currentPath as NSString).appendingPathComponent(newPath)
        return self
    }

    @discardableResult
    func addQueryItem(name: String, value: String) -> URLBuilder {
        if components.queryItems == nil {
            components.queryItems = []
        }
        components.queryItems?.append(URLQueryItem(name: name, value: value))
        return self
    }

    func build() -> URL? {
        return components.url
    }
}

extension URLBuilder {

    static func movie(listType: MovieListType, page: Int) -> URL? {
        let builder = URLBuilder(environment: MoviedbEnvironment.tmdbAPI)
        return builder
            .appendPath("movie")
            .appendPath(listType.rawValue)
            .addQueryItem(name: "language", value: "en-US")
            .addQueryItem(name: "page", value: "\(page)")
            .build()
    }

    static func tv(listType: TVListType, page: Int) -> URL? {
        let builder = URLBuilder(environment: MoviedbEnvironment.tmdbAPI)
        return builder
            .appendPath("tv")
            .appendPath(listType.rawValue)
            .addQueryItem(name: "language", value: "en-US")
            .addQueryItem(name: "page", value: "\(page)")
            .build()
    }

    static func image(type: TMDBImageType, size: TMDBImageSize = .w500) -> URL? {
        let builder = URLBuilder(environment: MoviedbEnvironment.tmdbImage)
        return builder
            .appendPath(size.rawValue)
            .appendPath(type.path)
            .addQueryItem(name: "language", value: "en-US")
            .build()
    }
}

extension URLBuilder {

    static func search(
        type: SearchType,
        query: String,
        page: Int
    ) -> URL? {

        let builder = URLBuilder(environment: MoviedbEnvironment.tmdbAPI)

        return builder
            .appendPath("search")
            .appendPath(type.rawValue)
            .addQueryItem(name: "query", value: query)
            .addQueryItem(name: "page", value: "\(page)")
            .addQueryItem(name: "language", value: "en-US")
            .build()
    }
}
