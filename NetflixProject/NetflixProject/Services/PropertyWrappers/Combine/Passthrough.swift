//
//  Passthrough.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation
import Combine

@propertyWrapper
class Passthrough<Event, Failure, SubjectType: PassthroughSubject<Event, Failure>> {

    let combine: PassthroughSubject<Event, Failure>

    var wrappedValue: AnyPublisher<Event, Failure> {
        return combine.eraseToAnyPublisher()
    }

    init() {
        combine = PassthroughSubject()
    }
}
