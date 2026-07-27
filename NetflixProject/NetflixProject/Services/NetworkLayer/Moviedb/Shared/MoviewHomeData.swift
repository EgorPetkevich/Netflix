//
//  MoviewHomeData.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 13.04.26.
//

import Foundation
import Storage

struct MoviewHomeData {
    let nowPlaying: [any MediaDTODescription]
    let popular: [any MediaDTODescription]
    let topRated: [any MediaDTODescription]
    let upcoming: [any MediaDTODescription]
}
