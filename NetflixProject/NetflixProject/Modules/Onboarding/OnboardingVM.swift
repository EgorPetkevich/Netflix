//
//  OnboardingVM.swift
//  NetflixProject
//
//  Created by George Popkich on 30.03.26.
//

import Foundation
import RxSwift
import RxRelay

protocol OnboardingCoordinatorProtocol: AnyObject {
    func openLogin()
    func openRegistration()
}

final class OnboardingVM: OnboardingViewModelProtocol {

    // In
    var signInButtonSubject: PublishSubject<Void> = .init()
    var signUpButtonSubject: PublishSubject<Void> = .init()

    private weak var coordinator: OnboardingCoordinatorProtocol?

    private var bag = DisposeBag()

    init(coordinator: OnboardingCoordinatorProtocol) {
        self.coordinator = coordinator
        bind()
    }

    private func bind() {
        signInButtonSubject.subscribe(onNext: { [weak self] in
            UDManager.set(.isOnboardingPassed, value: true)
            self?.coordinator?.openLogin()
        })
        .disposed(by: bag)

        signUpButtonSubject.subscribe(onNext: { [weak self] in
            UDManager.set(.isOnboardingPassed, value: true)
            self?.coordinator?.openRegistration()
        })
        .disposed(by: bag)
    }

}
