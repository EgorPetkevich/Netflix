//
//  FetchTokenError.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 13.04.26.
//

import Foundation

enum FetchTokenError: Error {
    case noUser
    case documentNotFound
    case tokenMissing
}
