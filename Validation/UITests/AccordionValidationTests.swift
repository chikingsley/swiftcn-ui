import XCTest

final class AccordionValidationTests: ValidationCase {
    func testControlledSingleCollapsibleRoutesBindingCallbackAndContent() {
        let app = launchHost(scene: "accordion")
        let trigger = app.buttons["accordion-controlled-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertEqual(trigger.value as? String, "Collapsed")

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["accordion-controlled-echo"]), "Controlled: controlled")
        XCTAssertEqual(
            text(of: app.staticTexts["accordion-controlled-callback"]),
            "Controlled callback: controlled"
        )
        XCTAssertTrue(app.staticTexts["accordion-controlled-content"].waitForExistence(timeout: 2))

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["accordion-controlled-echo"]), "Controlled: none")
        XCTAssertTrue(app.staticTexts["accordion-controlled-content"].waitForNonExistence(timeout: 2))
        attachWindowScreenshot(of: app, named: "accordion-light")
    }

    func testNoncollapsibleSingleStaysOpenAndDisabledItemIsDisabled() {
        let app = launchHost(scene: "accordion")
        let required = app.buttons["accordion-required-trigger"]
        XCTAssertTrue(required.waitForExistence(timeout: 5))
        XCTAssertEqual(required.value as? String, "Expanded")
        XCTAssertTrue(app.staticTexts["accordion-required-content"].exists)

        required.click()
        XCTAssertEqual(required.value as? String, "Expanded")
        XCTAssertTrue(app.staticTexts["accordion-required-content"].exists)
        XCTAssertEqual(text(of: app.staticTexts["accordion-internal-callback"]), "Internal callback: none")

        app.buttons["accordion-other-trigger"].click()
        XCTAssertTrue(app.staticTexts["accordion-required-content"].waitForNonExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["accordion-other-content"].waitForExistence(timeout: 2))
        XCTAssertEqual(text(of: app.staticTexts["accordion-internal-callback"]), "Internal callback: other")

        let disabled = app.buttons["accordion-disabled-trigger"]
        XCTAssertTrue(disabled.exists)
        XCTAssertFalse(disabled.isEnabled)
    }

    func testMultipleModeExpandsAndCollapsesIndependentItems() {
        let app = launchHost(scene: "accordion")
        let alpha = app.buttons["Alpha"]
        let beta = app.buttons["Beta"]
        XCTAssertTrue(alpha.waitForExistence(timeout: 5))
        XCTAssertTrue(beta.exists)

        alpha.click()
        beta.click()
        XCTAssertTrue(app.staticTexts["accordion-alpha-content"].exists)
        XCTAssertTrue(app.staticTexts["accordion-beta-content"].exists)
        XCTAssertEqual(text(of: app.staticTexts["accordion-multiple-callback"]), "Multiple callback: alpha,beta")

        alpha.click()
        XCTAssertFalse(app.staticTexts["accordion-alpha-content"].exists)
        XCTAssertTrue(app.staticTexts["accordion-beta-content"].exists)
        XCTAssertEqual(text(of: app.staticTexts["accordion-multiple-callback"]), "Multiple callback: beta")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "accordion", appearance: "dark")
        XCTAssertTrue(app.buttons["accordion-controlled-trigger"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "accordion-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "accordion", appearance: "light")
        XCTAssertTrue(app.buttons["accordion-controlled-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "accordion", appearance: "dark")
        XCTAssertTrue(app.buttons["accordion-controlled-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
