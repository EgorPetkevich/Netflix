//
//  StorageService.swift
//  Storage
//
//  Created by Egor Petkevich on 28.04.26.
//

import Foundation
import SwiftData

public class StorageService {

    public static var shared: StorageService = .init()

    private let container: ModelContainer
    public let mainContext: ModelContext

    private init() {
        do {
            container = try ModelContainer(
                for: MovieMO.self,
                PersonMO.self,
                TvMO.self,
            )
            mainContext = ModelContext(container)
            mainContext.autosaveEnabled = true
        } catch {
            fatalError("Error initializing ModelContainer: \(error)")
        }
    }

    public static func deleteModels() throws {
        let context = shared.mainContext

        try context.delete(model: MovieMO.self)
        try context.delete(model: TvMO.self)
        try context.delete(model: PersonMO.self)

        try context.save()

        shared = StorageService()
    }

    func makeBackgroundContext(autosave: Bool = false) -> ModelContext {
        let ctx = ModelContext(container)
        ctx.autosaveEnabled = autosave
        return ctx
    }

    func save(
        context: ModelContext,
        completion: @escaping (Bool) -> Void
    ) {
        if context.hasChanges {
            do {
                try context.save()
                completion(true)
            } catch {
                completion(false)
                print("[StorageService]:", "Cannot save context, error: \(error.localizedDescription)")
            }
        }
    }

}
