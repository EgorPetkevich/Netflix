//
//  HomeUITests.swift
//  NetflixProjectUITests
//
//  Created by Egor Petkevich on 1.07.26.
//

import XCTest

final class HomeScreenUITests: BaseUITestCase {

    override func setUpWithError() throws {
        try super.setUpWithError()
        launchApp()
    }

    @MainActor
    func test_homeScreen_isVisibleAfterLaunch() throws {
        let homeScreen = app.otherElements[AccessibilityIdentifiers.Home.screen]

        XCTAssertTrue(homeScreen.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_homeTableView_isVisibleAfterLaunch() throws {
        let tableView = app.tables[AccessibilityIdentifiers.Home.tableView]

        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_homeTab_isVisible() throws {
        let homeTab = app.tabBars.buttons["Home"]

        XCTAssertTrue(homeTab.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_homeTableView_hasContent() throws {
        let tableView = app.tables[AccessibilityIdentifiers.Home.tableView]

        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        XCTAssertGreaterThan(tableView.cells.count, 0)
    }

    @MainActor
    func test_tapFirstHomeItem_openDetailsScreen() throws {
        let tableView = app.tables[AccessibilityIdentifiers.Home.tableView]

        XCTAssertTrue(tableView.waitForExistence(timeout: 10))

        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 10))

        firstCell.tap()

        let detailsScreen = app.otherElements[AccessibilityIdentifiers.Details.Movie.screen]
        XCTAssertTrue(detailsScreen.waitForExistence(timeout: 10))
    }
}
