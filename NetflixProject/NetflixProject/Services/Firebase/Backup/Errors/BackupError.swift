//
//  BackupError.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 5.05.26.
//

import Foundation

enum BackupError: Error {
    case userNotAuthenticated
    case invalidSnapshot
    case decodingFailed(Error)
    case unsupportedType
}
