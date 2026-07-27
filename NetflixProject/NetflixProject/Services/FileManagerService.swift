//
//  FileManagerService.swift
//  NetflixProject
//
//  Created by Egor Petkevich on 11.05.26.
//

import Foundation
import UIKit

final class FileManagerService {

    private let folderName = "NotificationAttachments"

    private var folderURL: URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent(folderName, isDirectory: true)
    }

    init() {
        createFolderIfNeeded()
    }

    func saveImage(_ image: UIImage, id: String) throws -> URL {
        createFolderIfNeeded()

        guard let data = image.jpegData(compressionQuality: 0.9) else {
            throw NotiServiceError.imagePathNotFound
        }

        let fileURL = folderURL
            .appendingPathComponent(id)
            .appendingPathExtension("jpg")

        try data.write(to: fileURL, options: .atomic)

        return fileURL
    }

    func makeAttachment(
        image: UIImage,
        id: String
    ) throws -> UNNotificationAttachment {

        let fileURL = try saveImage(image, id: id)

        return try UNNotificationAttachment(
            identifier: id,
            url: fileURL
        )
    }

    func deleteImage(id: String) {
        let fileURL = folderURL
            .appendingPathComponent(id)
            .appendingPathExtension("jpg")

        try? FileManager.default.removeItem(at: fileURL)
    }

    func deleteAll() {
        try? FileManager.default.removeItem(at: folderURL)
        createFolderIfNeeded()
    }

    private func createFolderIfNeeded() {
        guard
            !FileManager.default.fileExists(atPath: folderURL.path)
        else { return }

        try? FileManager.default.createDirectory(
            at: folderURL,
            withIntermediateDirectories: true
        )
    }
}
