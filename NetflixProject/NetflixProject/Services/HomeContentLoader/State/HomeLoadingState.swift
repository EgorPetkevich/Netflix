//
//  HomeLoadingState.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 18.05.26.
//

import Foundation

enum HomeLoadingState: Equatable {
    case idle
    case loading
    case ready
    case failed(String)
}
