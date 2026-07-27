//
//  FirestoreService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 4.05.26.
//

import Foundation
import FirebaseDatabaseInternal
import FirebaseAuth
import Storage

final class FireBaseBackupService {

    private var ref: DatabaseReference {
        return Database.database().reference()
    }

    private var userId: String? {
        return Auth.auth().currentUser?.uid
    }

    private let logger = Logger(FireBaseBackupService.self)

    func send(dto: any MediaDTODescription) {
        guard let userId else { return }
        guard let type = ChildType.get(dto) else { return }

        Task.detached(priority: .background) {
            let backupModel = BackupModel(dto: dto)
            guard let dict = backupModel.buidDict() else { return }

            self.ref
                .child("users")
                .child(userId)
                .child(type)
                .child(dto.id)
                .setValue(dict)
        }
    }

    func delete(dto: any MediaDTODescription) {
        guard let userId else { return }
        guard let type = ChildType.get(dto) else { return }

        Task.detached(priority: .background) {
            self.ref
                .child("users")
                .child(userId)
                .child(type)
                .child(dto.id)
                .removeValue()
        }
    }

    func load() async throws -> [any MediaDTODescription] {
        guard let userId else { throw BackupError.userNotAuthenticated }

        let snapshot = try await ref
            .child("users")
            .child(userId)
            .getData()

        guard
            let root = snapshot.value as? [String: Any]
        else { throw BackupError.invalidSnapshot }

        var result: [BackupModel] = []

        for type in BackupCollection.allCases {
            guard
                let items = root[type.rawValue] as? [String: Any]
            else { continue }

            for (_, value) in items {
                if let dict = value as? [String: Any],
                   let data = try? JSONSerialization.data(withJSONObject: dict) {
                    do {
                        let model = try JSONDecoder().decode(
                            BackupModel.self,
                            from: data
                        )
                        result.append(model)
                    } catch {
                        logger.error(error.localizedDescription)
                        throw BackupError.decodingFailed(error)
                    }
                }
            }
        }

        return result.map { $0.dto }
    }
}
