//
//  MovieDetailsUITests.swift
//  NetflixProjectUITests
//
//  Created by Egor Petkevich on 1.07.26.
//

import XCTest

final class MovieDetailsUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        launchApp(arguments: ["--screen-movie-details"])
    }

    @MainActor
    func test_movieDetailsScreen_isVisible() throws {
        let screen = app.otherElements[AccessibilityIdentifiers.Details.Movie.screen]

        XCTAssertTrue(screen.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_movieDetailsContent_isVisible() throws {
        let titleLabel = app.staticTexts[AccessibilityIdentifiers.Details.Movie.titleLabel]
        let overviewLabel = app.staticTexts[AccessibilityIdentifiers.Details.Movie.overviewLabel]

        XCTAssertTrue(titleLabel.waitForExistence(timeout: 10))
        XCTAssertTrue(overviewLabel.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_tapLikeButton_changesLikeState() throws {
        let likeButton = app.buttons[AccessibilityIdentifiers.Details.Movie.LikeButton.button]

        XCTAssertTrue(likeButton.waitForExistence(timeout: 10))
        XCTAssertEqual(
            likeButton.value as? String,
            AccessibilityIdentifiers.Details.Movie.LikeButton.Value.notLiked
        )

        likeButton.tap()

        XCTAssertEqual(
            likeButton.value as? String,
            AccessibilityIdentifiers.Details.Movie.LikeButton.Value.liked
        )
    }

    @MainActor
    func test_tapBookmarkButton_changesBookmarkState() throws {
        let bookmarkButton = app.buttons[AccessibilityIdentifiers.Details.Movie.BookmarkButton.button]

        XCTAssertTrue(bookmarkButton.waitForExistence(timeout: 10))
        XCTAssertEqual(
            bookmarkButton.value as? String,
            AccessibilityIdentifiers.Details.Movie.BookmarkButton.Value.notBookmarked
        )

        bookmarkButton.tap()

        XCTAssertEqual(
            bookmarkButton.value as? String,
            AccessibilityIdentifiers.Details.Movie.BookmarkButton.Value.bookmarked
        )
    }
}
