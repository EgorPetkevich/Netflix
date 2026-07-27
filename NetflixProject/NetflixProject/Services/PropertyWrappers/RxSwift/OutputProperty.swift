//
//  OutputProperty.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RxSwift
import RxRelay

@propertyWrapper
class OutputProperty<Event, RxObserver: ObservableConvertibleType>
                    where Event == RxObserver.Element {

    let rx: RxObserver

    var wrappedValue: Observable<Event> {
        return rx.asObservable()
    }

    init(value: RxObserver.Element, type: RxObserver.Type)
        where RxObserver: RxValueObserver {

        rx = type.init(value: value)
    }

    init(type: RxObserver.Type)
        where RxObserver: RxPublishObserver {

        rx = type.init()
    }
}
