import XCTest

final class TextareaValidationTests: ValidationCase {
    private let identifiers = [
        "textarea-default", "textarea-tall", "textarea-compact", "textarea-invalid",
        "textarea-disabled",
    ]

    func testEveryHeightAndStateRenders() {
        let app = launchHost(scene: "textarea")
        XCTAssertTrue(app.textViews["textarea-default"].waitForExistence(timeout: 5))

        for identifier in identifiers {
            XCTAssertTrue(app.textViews[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertGreaterThan(
            app.textViews["textarea-tall"].frame.height,
            app.textViews["textarea-compact"].frame.height
        )
        attachWindowScreenshot(of: app, named: "textarea-light")
    }

    func testMultilineTypingRoutesIntoCallerOwnedBinding() {
        let app = launchHost(scene: "textarea")
        let editor = app.textViews["textarea-default"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        editor.click()
        editor.typeText("First line\nSecond line")
        XCTAssertEqual(
            text(of: app.staticTexts["textarea-value-echo"]),
            "Message: First line\nSecond line"
        )
    }

    func testDisabledTextareaIsExposedAsDisabled() {
        let app = launchHost(scene: "textarea")
        let editor = app.textViews["textarea-disabled"]
        XCTAssertTrue(editor.waitForExistence(timeout: 5))
        XCTAssertFalse(editor.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "textarea", appearance: "dark")
        XCTAssertTrue(app.textViews["textarea-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "textarea-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "textarea", appearance: "light")
        XCTAssertTrue(app.textViews["textarea-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "textarea", appearance: "dark")
        XCTAssertTrue(app.textViews["textarea-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
