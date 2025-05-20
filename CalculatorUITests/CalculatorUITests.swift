// CalculatorUITests/CalculatorUITests.swift

import XCTest

class CalculatorUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // Existing tests...
    // func testButtonsLabelsExist() { ... }
    // func testCommasDisplayed() { ... }
    // func testDecimalDisplayed() { ... }
    // func test8DecimalsOnly() { ... }
    // func testProperRounding() { ... }
    // func testDoubleDotConvertsToZero() { ... }
    // func testMultipleDotsConvertToZero() { ... }
    // func testNan() { ... }
    // func testInfinity() { ... }
    // func testSelectionVCExists() { ... }


    // MARK: - New Arithmetic Tests

    func testAddition() {
        app.buttons["5"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()
        app.buttons["="].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "8")
    }

    func testSubtraction() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["−"].tap() // Note: This is the minus sign, not hyphen
        app.buttons["4"].tap()
        app.buttons["="].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "6")
    }

    func testMultiplication() {
        app.buttons["6"].tap()
        app.buttons["×"].tap()
        app.buttons["7"].tap()
        app.buttons["="].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "42")
    }

    func testDivision() {
        app.buttons["2"].tap()
        app.buttons["0"].tap()
        app.buttons["÷"].tap()
        app.buttons["5"].tap()
        app.buttons["="].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "4")
    }

    func testDecimalAddition() {
        app.buttons["1"].tap()
        app.buttons["."].tap()
        app.buttons["5"].tap()
        app.buttons["+"].tap()
        app.buttons["2"].tap()
        app.buttons["."].tap()
        app.buttons["5"].tap()
        app.buttons["="].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "4")
    }

    // MARK: - New Chaining Operations Tests

    func testChainingAdditionAndSubtraction() {
        app.buttons["5"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()
        app.buttons["−"].tap() // Performs 5+3=8, then sets up 8-
        app.buttons["2"].tap()
        app.buttons["="].tap() // Performs 8-2=6
        XCTAssertEqual(app.staticTexts["display"].label, "6")
    }

    func testChainingMultiplicationAndDivision() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["×"].tap() // Sets up 10*
        app.buttons["5"].tap()
        app.buttons["÷"].tap() // Performs 10*5=50, then sets up 50/
        app.buttons["2"].tap()
        app.buttons["="].tap() // Performs 50/2=25
        XCTAssertEqual(app.staticTexts["display"].label, "25")
    }

    func testComplexChaining() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["+"].tap() // Sets up 10+
        app.buttons["5"].tap()
        app.buttons["×"].tap() // Performs 10+5=15 (Note: Calculator logic might differ, assuming left-to-right or immediate execution)
                               // Based on CalculatorCompute, it performs the pending op when a new binary op is pressed.
                               // So 10 + 5 -> press × -> performs 10+5=15, then sets up 15 × ...
        XCTAssertEqual(app.staticTexts["display"].label, "15") // Check intermediate result
        app.buttons["2"].tap()
        app.buttons["="].tap() // Performs 15 * 2 = 30
        XCTAssertEqual(app.staticTexts["display"].label, "30")
    }

    // MARK: - New Unary Operations Tests

    func testSquareRoot() {
        app.buttons["8"].tap()
        app.buttons["1"].tap()
        app.buttons["√"].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "9")
    }

    func testPlusMinus() {
        app.buttons["2"].tap()
        app.buttons["5"].tap()
        app.buttons["±"].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "-25")

        app.buttons["±"].tap() // Apply again
        XCTAssertEqual(app.staticTexts["display"].label, "25")
    }

    func testPiConstant() {
        app.buttons["π"].tap()
        // Check if the display contains "3.14159265" (or similar, depending on formatting)
        // Using starts(with:) or contains() might be safer than exact match due to formatting
        XCTAssertTrue(app.staticTexts["display"].label.starts(with: "3.14159265"), "Pi constant should be displayed")
    }

    func testACButton() {
        app.buttons["1"].tap()
        app.buttons["2"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "3") // Display shows the second operand

        app.buttons["AC"].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "0", "AC should clear the display")

        // Check if pending operation is also cleared (perform equals, result should still be 0)
        app.buttons["="].tap()
        XCTAssertEqual(app.staticTexts["display"].label, "0", "AC should also clear pending operations")
    }

    func testUnaryAfterBinary() {
        app.buttons["1"].tap()
        app.buttons["0"].tap()
        app.buttons["×"].tap() // Sets up 10 * ...
        app.buttons["9"].tap()
        app.buttons["√"].tap() // Applies sqrt to 9, display becomes 3
        XCTAssertEqual(app.staticTexts["display"].label, "3")
        app.buttons["="].tap() // Performs 10 * 3 = 30
        XCTAssertEqual(app.staticTexts["display"].label, "30")
    }

    // MARK: - New Theme Selection Test

    func testThemeSelection() {
        // Open the theme selection view
        app.buttons["◉"].tap()

        // Check if the selection view exists (already covered by testSelectionVCExists, but good to re-verify flow)
        let selectionVC = app.otherElements["selectionVC"]
        XCTAssertTrue(selectionVC.exists)

        // Tap on a specific theme button (e.g., theme 2)
        let themeButton2 = app.buttons["themeButton_2"] // Requires accessibility identifier set in storyboard
        XCTAssertTrue(themeButton2.exists, "Theme button with identifier 'themeButton_2' should exist")
        themeButton2.tap()

        // Verify the selection view is dismissed
        let selectionVCDoesNotExist = selectionVC.waitForExistence(timeout: 2.0) // Wait for dismissal
        XCTAssertFalse(selectionVCDoesNotExist, "Selection view controller should be dismissed after selection")

        // Note: Verifying the theme actually changed visually is complex in UI tests.
        // We can only verify the interaction flow (opening, selecting, dismissing).
        // Unit tests or snapshot tests would be better for verifying visual theme changes.
    }

    // MARK: - Edge Cases / Combinations

    func testOperationAfterEquals() {
        app.buttons["5"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()
        app.buttons["="].tap() // Result is 8
        XCTAssertEqual(app.staticTexts["display"].label, "8")

        app.buttons["+"].tap() // Sets up 8 + ...
        app.buttons["2"].tap()
        app.buttons["="].tap() // Performs 8 + 2 = 10
        XCTAssertEqual(app.staticTexts["display"].label, "10")
    }

    func testMultipleEquals() {
        app.buttons["5"].tap()
        app.buttons["+"].tap()
        app.buttons["3"].tap()
        app.buttons["="].tap() // Result 8
        XCTAssertEqual(app.staticTexts["display"].label, "8")

        app.buttons["="].tap() // Pressing equals again should not change the result
        XCTAssertEqual(app.staticTexts["display"].label, "8")
    }
}
