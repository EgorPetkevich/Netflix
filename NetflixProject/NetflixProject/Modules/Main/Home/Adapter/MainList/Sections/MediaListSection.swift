//
//  MediaListSection.swift
//  NetflixProject
//
//  Created by George Popkich on 8.04.26.
//

import UIKit
import Storage

struct MediaListSection {
    let type: MediaSectionType
    var media: [any MediaDTODescription]

    var page: Int = 1
    var isLoading: Bool = false

    var title: String {
        type.title
    }
}
