//
//  TvDetailsUITests.swift
//  NetflixProjectUITests
//
//  Created by Egor Petkevich on 2.07.26.
//

import XCTest

final class TvDetailsUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        launchApp(arguments: ["--screen-tv-details"])
    }

    @MainActor
    func test_tvDetailsScreen_isVisible() throws {
        let screen = app.otherElements[AccessibilityIdentifiers.Details.Tv.screen]

        XCTAssertTrue(screen.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_movieDetailsContent_isVisible() throws {
        let titleLabel = app.staticTexts[AccessibilityIdentifiers.Details.Tv.titleLabel]
        let overviewLabel = app.staticTexts[AccessibilityIdentifiers.Details.Tv.overviewLabel]

        XCTAssertTrue(titleLabel.waitForExistence(timeout: 10))
        XCTAssertTrue(overviewLabel.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_tapLikeButton_changesLikeState() throws {
        let likeButton = app.buttons[AccessibilityIdentifiers.Details.Tv.LikeButton.button]

        XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
        XCTAssertEqual(
            likeButton.value as? String,
            AccessibilityIdentifiers.Details.Tv.LikeButton.Value.notLiked
        )

        likeButton.tap()

        XCTAssertEqual(
            likeButton.value as? String,
            AccessibilityIdentifiers.Details.Tv.LikeButton.Value.liked
        )
    }

    @MainActor
    func test_tapBookmarkButton_changesBookmarkState() throws {
        let bookmarkButton = app.buttons[AccessibilityIdentifiers.Details.Tv.BookmarkButton.button]

        XCTAssertTrue(bookmarkButton.waitForExistence(timeout: 10))
        XCTAssertEqual(
            bookmarkButton.value as? String,
            AccessibilityIdentifiers.Details.Tv.BookmarkButton.Value.notBookmarked
        )

        bookmarkButton.tap()

        XCTAssertEqual(
            bookmarkButton.value as? String,
            AccessibilityIdentifiers.Details.Tv.BookmarkButton.Value.bookmarked
        )
    }
}
