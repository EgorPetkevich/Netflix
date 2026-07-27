//
//  TheMovieDBRequest.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 21.04.26.
//

import Foundation

struct TheMovieDBRequest<Response: Decodable>: NetworkRequest {

    typealias ResponseModel = Response

    var apiToken: String

    var url: URL?

    var method: NetworkHTTPMethod { .get }

    var headers: [String: String] {
        [
            "accept": "application/json",
            "Authorization": "Bearer" + " " + apiToken
        ]
    }

    var body: Data? { nil }

    var urlRequest: URLRequest {
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = method.rawValue
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpBody = body
        return urlRequest
    }

}
