//
//  ToDo_TaskUITests.swift
//  ToDo TaskUITests
//
//  Created by francisco eduardo aramburo reyes on 06/01/26.
//

import XCTest

final class ToDo_TaskUITests: XCTestCase {

    let app = XCUIApplication()
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    func testLaunchInEnglish() {
        app.launchArguments = ["--language", "en"] // set the language
        app.launch()
        
        let header = app.staticTexts["Select the working profile"]
        XCTAssertTrue(header.exists, "The english header of 'Select the working profile' is not found")
    }
    func testLaunchInSpanish() {
            app.launchArguments = ["-AppleLanguages", "(es)"] // set the language
            app.launch()
            let header = app.staticTexts["Seleccione el perfil de trabajo"]
            XCTAssertTrue(header.exists, "The spanish header of 'Select the working profile' in spanish is not found")
        }
    func testNewGroupCreationIcons() {
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()
        
        let firstProfile = app.buttons.firstMatch
        if firstProfile.exists {
            firstProfile.tap()
            
            let addButton = app.buttons["Add"]
            if addButton.waitForExistence(timeout: 2) {
                addButton.tap()
                
                XCTAssertTrue(app.staticTexts["Group Name"].exists)
                XCTAssertTrue(app.staticTexts["Select Icon"].exists)
            }
        }
    }
}
