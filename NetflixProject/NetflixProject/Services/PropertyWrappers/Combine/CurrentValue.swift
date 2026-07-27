//
//  CurrentValue.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation
import Combine

@propertyWrapper
class CurrentValue<Event, Failure, SubjectType: CurrentValueSubject<Event, Failure>> {

    let combine: CurrentValueSubject<Event, Failure>

    var wrappedValue: AnyPublisher<Event, Failure> {
        return combine.eraseToAnyPublisher()
    }

    init(value: Event) {
        combine = CurrentValueSubject(value)
    }
}
