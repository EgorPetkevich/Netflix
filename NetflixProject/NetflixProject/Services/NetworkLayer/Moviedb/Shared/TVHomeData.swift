//
//  TVHomeData.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 13.04.26.
//

import Foundation
import Storage

struct TVHomeData {
    let airingToday: [any MediaDTODescription]
    let onTheAir: [any MediaDTODescription]
    let popular: [any MediaDTODescription]
    let topRated: [any MediaDTODescription]
}
