//
//  NetflixProjectUITests.swift
//  NetflixProjectUITests
//
//  Created by Egor Petkevich on 1.07.26.
//

import XCTest

final class NetflixProjectUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func test_homeScreen_isVisibleAfterLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()

        let homeScreen = app.otherElements["homeScreen"]
        XCTAssertTrue(homeScreen.waitForExistence(timeout: 10))
    }

    @MainActor
    func test_homeTableView_isVisibleAfterLaunch() throws {
        let app = XCUIApplication()
        app.launchArguments.append("--ui-testing")
        app.launch()

        let tableView = app.tables["homeTableView"]
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
    }
}
