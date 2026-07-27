//
//  Relay.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RxSwift
import RxRelay

@propertyWrapper
class Relay<Event, RxObserver: ObservableConvertibleType>:
        OutputProperty<Event, RxObserver> where Event == RxObserver.Element {

    override var wrappedValue: Observable<Event> {
        return rx.asObservable()
    }

    init(value: Event) where RxObserver == BehaviorRelay<Event> {
        super.init(value: value, type: BehaviorRelay.self)
    }

    init() where RxObserver == PublishRelay<Event> {
        super.init(type: PublishRelay.self)
    }
}
