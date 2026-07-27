//
//  BaseUITestCase.swift
//  NetflixProjectUITests
//
//  Created by Egor Petkevich on 1.07.26.
//

import XCTest

class BaseUITestCase: XCTestCase {

    var app: XCUIApplication!

    func launchApp(arguments: [String] = []) {
        app = XCUIApplication()
        app.launchArguments = [AppLaunchArguments.uiTesting] + arguments
        app.launch()
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
    }
}
