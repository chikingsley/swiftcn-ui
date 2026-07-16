import XCTest

final class InputOTPValidationTests: ValidationCase {
    private let identifiers = [
        "inputotp-digits", "inputotp-alphanumeric", "inputotp-custom", "inputotp-invalid",
        "inputotp-disabled",
    ]

    func testEveryPatternCompositionAndStateRenders() {
        let app = launchHost(scene: "inputotp")
        XCTAssertTrue(app.textFields["inputotp-digits"].waitForExistence(timeout: 5))

        for identifier in identifiers {
            XCTAssertTrue(app.textFields[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertEqual(
            app.textFields["inputotp-alphanumeric"].value as? String,
            "A 1, 2 of 4 characters entered"
        )
        XCTAssertEqual(
            app.textFields["inputotp-custom"].value as? String,
            "A B, 2 of 4 characters entered"
        )
        attachWindowScreenshot(of: app, named: "inputotp-light")
    }

    func testTypingFullCodeRoutesBindingAndCompletionCallback() {
        let app = launchHost(scene: "inputotp")
        let field = app.textFields["inputotp-digits"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.click()
        field.typeText("123456")
        XCTAssertEqual(text(of: app.staticTexts["inputotp-code-echo"]), "Code: 123456")
        XCTAssertEqual(
            text(of: app.staticTexts["inputotp-completion-echo"]),
            "Completed: 123456"
        )
        XCTAssertEqual(field.value as? String, "1 2 3 4 5 6, 6 of 6 characters entered")
    }

    func testInvalidAndDisabledValuesExposeNativeTextEntryState() {
        let app = launchHost(scene: "inputotp")
        let invalid = app.textFields["inputotp-invalid"]
        let disabled = app.textFields["inputotp-disabled"]
        XCTAssertTrue(invalid.waitForExistence(timeout: 5))
        XCTAssertEqual(invalid.value as? String, "1 2, 2 of 4 characters entered")
        XCTAssertFalse(disabled.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "inputotp", appearance: "dark")
        XCTAssertTrue(app.textFields["inputotp-digits"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "inputotp-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "inputotp", appearance: "light")
        XCTAssertTrue(app.textFields["inputotp-digits"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "inputotp", appearance: "dark")
        XCTAssertTrue(app.textFields["inputotp-digits"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
