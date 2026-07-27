//
//  MediaDataWorker+Notification.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import Foundation
import Storage

extension NotificationService: MediaDataWorkerNotiServiceUseCaseProtocol {

    func makeNotifications(from dtos: [MovieDTO]) {
        dtos.forEach { dto in
            self.updateOrCreateNotification(dto: dto)
        }
    }

    func removeNotifications(ids: [String]) {
        ids.forEach { id in
            self.removeNotification(id: id)
        }
    }

}
