import XCTest

final class CaptureViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureTextEntry() throws {
        let app = XCUIApplication()
        app.launch()

        // Assuming the TextEditor is the first text view.
        let textView = app.textViews.firstMatch
        XCTAssertTrue(textView.waitForExistence(timeout: 2))

        textView.tap()
        textView.typeText("New capture idea")

        // Verify text exists
        XCTAssertEqual(textView.value as? String, "New capture idea")
    }
}
