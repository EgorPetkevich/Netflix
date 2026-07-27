//
//  NetworkRequest.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 9.04.26.
//

import Foundation

enum NetworkHTTPMethod: String {
    case get = "GET"
}

protocol NetworkRequest {
    associatedtype ResponseModel: Decodable

    var url: URL? { get }
    var method: NetworkHTTPMethod { get }
    var headers: [String: String] { get }
    var body: Data? { get }
    var urlRequest: URLRequest { get }
}
