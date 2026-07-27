//
//  FetchDescriptors.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

extension FetchDescriptor where T: MediaMODescription {

    static func byId(_ id: String) -> FetchDescriptor<T> {
        let predicate = #Predicate<T> { $0.id == id }
        return FetchDescriptor<T>(predicate: predicate)
    }

    static func byDate() -> FetchDescriptor<T> {
        let timeSortDescriptor = SortDescriptor<T>(\.date)
        return FetchDescriptor<T>(sortBy: [timeSortDescriptor])
    }

}
