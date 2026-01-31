import XCTest

final class BinsViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testBinsListDisplay() throws {
        let app = XCUIApplication()
        app.launch()

        // Navigate to Bins tab
        let binsTab = app.tabBars.buttons["Bins"]
        XCTAssertTrue(binsTab.waitForExistence(timeout: 2))
        binsTab.tap()

        // Check for default bins
        XCTAssertTrue(app.staticTexts["Tasks"].exists)
        XCTAssertTrue(app.staticTexts["Ideas"].exists)
        XCTAssertTrue(app.staticTexts["Read/Watch"].exists)
    }
}
