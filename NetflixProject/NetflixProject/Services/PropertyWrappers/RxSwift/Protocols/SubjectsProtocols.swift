//
//  SubjectsProtocols.swift
//  BodyThermometerProject
//
//  Created by George Popkich on 29.06.25.
//

import Foundation
import RxSwift
import RxRelay

protocol RxPublishObserver: ObservableType {
    init()
}

protocol RxValueObserver: ObservableType {
    init(value: Element)
}

extension BehaviorSubject: RxValueObserver {}
extension BehaviorRelay: RxValueObserver {}

extension PublishSubject: RxPublishObserver {}
extension PublishRelay: RxPublishObserver {}
