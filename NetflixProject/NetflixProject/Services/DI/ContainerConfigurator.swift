//
//  ContainerConfigurator.swift
//  NetflixProject
//
//  Created by George Popkich on 26.03.26.
//

import Foundation
import Storage

final class ContainerConfigurator {

    private init() {}

    static func make() -> Container {
        let container = Container()

        registerHelpers(in: container)
        registerNetwork(in: container)
        registerStorage(in: container)
        registerServices(in: container)
        registerWorkers(in: container)

        return container
    }

    private static func registerHelpers(in container: Container) {
        container.lazyRegister { RxKeyboardHelper() }
        container.lazyRegister { CombineKeyboardHelper() }
        container.lazyRegister { InputValidator() }
        container.lazyRegister { KeychainManager() as KeychainManaging }
    }

    private static func registerNetwork(in container: Container) {
        let sessionProvider = NetworkSessionProvider()

        let fetchTokenService = FetchTokenService(
            keychainManager: container.resolve()
        )

        let mediaService = MediaService(
            session: sessionProvider,
            fetchTokenService: fetchTokenService
        )

        container.lazyRegister { sessionProvider }
        container.lazyRegister {
            sessionProvider as NetworkSessionProviderProtocol
        }

        container.lazyRegister { fetchTokenService }
        container.lazyRegister {
            fetchTokenService as FetchTokenServiceProtocol
        }

        container.lazyRegister {
            mediaService as MediaServiceProtocol
        }

    }

    private static func registerStorage(in container: Container) {
        container.lazyRegister { AllMediaStorage() }
        container.lazyRegister { MovieStorage() }
        container.lazyRegister { PersonStorage() }
        container.lazyRegister { TVStorage() }
    }

    private static func registerServices(in container: Container) {
        let backupService = FireBaseBackupService()
        let allMediaStorage = AllMediaStorage()
        let notificationService = NotificationService()
        let purchaseService = PurchaseService()
        let movieService = MovieService(mediaService: container.resolve())
        let tvService = TVService(mediaService: container.resolve())

        container.lazyRegister { backupService }
        container.lazyRegister { allMediaStorage }
        container.lazyRegister { notificationService }
        container.lazyRegister { purchaseService }
        container.lazyRegister { purchaseService as PurchaseServiceProtocol }

        container.lazyRegister {
            backupService as MediaDataWorkerBackupUseCaseProtocol
        }

        container.lazyRegister {
            allMediaStorage as MediaDataWorkerAllStoragesUseCaseProtocol
        }

        container.lazyRegister {
            notificationService as MediaDataWorkerNotiServiceUseCaseProtocol
        }

        container.lazyRegister { AuthService() }
        container.lazyRegister { AlertService(container: container) }
        container.lazyRegister { IdentifyService() }
        container.lazyRegister { PinCodeService(keychain: container.resolve()) }

        container.lazyRegister { movieService }

        container.lazyRegister {
            movieService as HomeMovieServiceUseCaseProtocol
        }

        container.lazyRegister { tvService }

        container.lazyRegister {
            tvService as HomeTVServiceUseCaseProtocol
        }

        container.lazyRegister {
            HomeContentLoader(
                movieService: container.resolve() as HomeMovieServiceUseCaseProtocol,
                tvService: container.resolve() as HomeTVServiceUseCaseProtocol
            )
        }

        container.lazyRegister {
            container.resolve() as HomeContentLoader as HomeContentLoaderProtocol
        }
    }

    private static func registerWorkers(in container: Container) {
        container.lazyRegister {
            MediaDataWorker(
                backup: container.resolve() as MediaDataWorkerBackupUseCaseProtocol,
                storage: container.resolve() as MediaDataWorkerAllStoragesUseCaseProtocol,
                notiService: container.resolve() as MediaDataWorkerNotiServiceUseCaseProtocol
            )
        }
    }
}
