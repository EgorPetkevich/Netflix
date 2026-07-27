//
//  KeyboardHalper+Reset.swift
//  NetflixProject
//
//  Created by George Popkich on 7.04.26.
//

import Foundation
import Combine

struct ResetKeyboardHalperUseCase: ResetKeyboardHalperUseCaseProtocol {

    var frame: AnyPublisher<CGRect, Never> {
        return helper.frame.eraseToAnyPublisher()
    }

    private let helper: CombineKeyboardHelper

    init(service: CombineKeyboardHelper) {
        self.helper = service
    }

}
