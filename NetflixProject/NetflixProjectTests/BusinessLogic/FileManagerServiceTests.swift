//
//  FileManagerServiceTests.swift
//  NetflixProjectTests
//
//  Created by Codex on 17.06.26.
//

import UIKit
import UserNotifications
import XCTest
@testable import NetflixProject

final class FileManagerServiceTests: XCTestCase {

    private var sut: FileManagerService!

    override func setUp() {
        super.setUp()
        sut = FileManagerService()
        sut.deleteAll()
    }

    override func tearDown() {
        sut.deleteAll()
        sut = nil
        super.tearDown()
    }

    func test_saveImage_writesJPEGFile() throws {
        let url = try sut.saveImage(makeImage(), id: "saved-image")

        XCTAssertEqual(url.lastPathComponent, "saved-image.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
    }

    func test_deleteImage_removesSavedFile() throws {
        let url = try sut.saveImage(makeImage(), id: "deleted-image")

        sut.deleteImage(id: "deleted-image")

        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
    }

    func test_deleteAll_removesImagesAndRecreatesFolder() throws {
        let url = try sut.saveImage(makeImage(), id: "all-images")

        sut.deleteAll()

        XCTAssertFalse(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: url.deletingLastPathComponent().path
            )
        )
    }

    func test_makeAttachment_returnsAttachmentForSavedImage() throws {
        let attachment = try sut.makeAttachment(
            image: makeImage(),
            id: "attachment-image"
        )

        XCTAssertEqual(attachment.identifier, "attachment-image")
        XCTAssertEqual(attachment.url.lastPathComponent, "attachment-image.jpg")
        XCTAssertTrue(FileManager.default.fileExists(atPath: attachment.url.path))
    }
}

private extension FileManagerServiceTests {
    func makeImage() -> UIImage {
        let size = CGSize(width: 2, height: 2)

        return UIGraphicsImageRenderer(size: size).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
