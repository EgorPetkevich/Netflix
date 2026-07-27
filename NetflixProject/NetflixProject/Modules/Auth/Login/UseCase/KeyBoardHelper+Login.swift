//
//  KeyBoardHelper+Login.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import Foundation
import RxSwift

struct LoginKeyboardHelperUseCase:
    LoginKeyboardHelperUseCaseProtocol {

    private let helper: RxKeyboardHelper

    var frame: Observable<CGRect> {
        return helper.frame.asObservable()
    }

    init(service: RxKeyboardHelper) {
        self.helper = service
    }

}
