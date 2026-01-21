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
    
    // MARK: 117 - 1
    
    func testUserFlow() throws {
        app.launchArguments = ["-savedProfile", ""]
        app.launch()
        
        sleep(1)
        
        print("🔍 Available buttons:")
            app.buttons.allElementsBoundByIndex.forEach { button in
                print("  - \(button.identifier)")
            }

        let professorCard = app.buttons["profileCard_Professor"] // GIVEN pre existing data
        XCTAssertTrue(professorCard.waitForExistence(timeout: 5), "The profile of professor should exist")
        professorCard.tap()
        
        let addGroupButton = app.buttons["addGroupButton"]
        XCTAssertTrue(addGroupButton.waitForExistence(timeout: 5) , "The add button should be visible on the dashboard")
        addGroupButton.tap()
        
        let groupNameField = app.textFields["newGroupNameField"]
        XCTAssertTrue(groupNameField.waitForExistence(timeout: 2), "The Group text field should be present")
        groupNameField.tap()
        groupNameField.typeText("Testing Project")
        
    // Dismiss Keyboard scenario
        
        if app.keyboards.buttons["Return"].exists { // if the simulator shows the keyboard
            app.keyboards.buttons["Return"].tap() // tap return to hide it after I finished typing
        } else {
            app.navigationBars["New Group Creator"].tap() // if NO keyboard shows (TODO: add accesibillity ID)
        }
        
        let iconButton = app.buttons["groupIcon_bookmark.fill"]
        if iconButton.exists {
            iconButton.tap()
        }
        
        let saveGroupButton = app.buttons["saveGroupButton"] // ID
        XCTAssertTrue(saveGroupButton.isHittable, "The save button is available")
        saveGroupButton.tap()

        let newGroupRow = app.buttons["groupRow_Testing Project"]
        XCTAssertTrue(newGroupRow.waitForExistence(timeout: 5), "The Testing Project group should be visible")
        newGroupRow.tap()

        let addTaskButton = app.buttons["addTaskButton"]
        XCTAssertTrue(addTaskButton.waitForExistence(timeout: 5), "The add task btn should be visible")
        addTaskButton.tap()

        let taskTextField = app.textFields.firstMatch
        taskTextField.tap()
        taskTextField.typeText("Finish UI Test")
        
    }
}



