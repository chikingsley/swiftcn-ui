import XCTest

final class InputValidationTests: ValidationCase {
    private let textFieldIdentifiers = [
        "input-text", "input-email", "input-telephone", "input-url", "input-number",
        "input-search", "input-integer", "input-double", "input-invalid", "input-disabled",
    ]

    func testEveryIntentValueTypeSizeAndStateRenders() {
        let app = launchHost(scene: "input")
        XCTAssertTrue(app.textFields["input-text"].waitForExistence(timeout: 5))

        for identifier in textFieldIdentifiers {
            XCTAssertTrue(app.textFields[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertTrue(app.secureTextFields["input-password"].exists)
        XCTAssertTrue(app.buttons["Clear search"].exists)
        attachWindowScreenshot(of: app, named: "input-light")
    }

    func testTypingRoutesIntoCallerOwnedStringBinding() {
        let app = launchHost(scene: "input")
        let field = app.textFields["input-text"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.click()
        field.typeText("Codex")
        XCTAssertEqual(text(of: app.staticTexts["input-text-echo"]), "Text: Codex")
    }

    func testSecureRevealAndTrailingAccessoryRouteActions() {
        let app = launchHost(scene: "input")
        XCTAssertTrue(app.secureTextFields["input-password"].waitForExistence(timeout: 5))

        app.buttons["Clear search"].click()
        XCTAssertEqual(text(of: app.staticTexts["input-accessory-count"]), "Accessory activations: 1")

        app.buttons["Show password"].click()
        XCTAssertTrue(app.textFields["input-password"].exists)
    }

    func testTypedBindingsExposeTheirInitialValues() {
        let app = launchHost(scene: "input")
        XCTAssertTrue(app.textFields["input-integer"].waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["input-typed-echo"]), "Integer: 7; Double: 1.5")
        XCTAssertEqual(app.textFields["input-integer"].value as? String, "7")
        XCTAssertEqual(app.textFields["input-double"].value as? String, "1.5")
    }

    func testDisabledInputIsExposedAsDisabled() {
        let app = launchHost(scene: "input")
        let field = app.textFields["input-disabled"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertFalse(field.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "input", appearance: "dark")
        XCTAssertTrue(app.textFields["input-text"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "input-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "input", appearance: "light")
        XCTAssertTrue(app.textFields["input-text"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "input", appearance: "dark")
        XCTAssertTrue(app.textFields["input-text"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
