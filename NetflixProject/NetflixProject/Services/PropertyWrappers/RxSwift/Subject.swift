//
//  Subject.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RxSwift

@propertyWrapper
class Subject<Event, RxObserver: ObservableConvertibleType>:
        OutputProperty<Event, RxObserver> where Event == RxObserver.Element {

    override var wrappedValue: Observable<Event> {
        return rx.asObservable()
    }

    init(value: Event) where RxObserver == BehaviorSubject<Event> {
        super.init(value: value, type: BehaviorSubject.self)
    }

    init() where RxObserver == PublishSubject<Event> {
        super.init(type: PublishSubject.self)
    }
}
