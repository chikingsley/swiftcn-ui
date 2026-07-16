import XCTest

final class CollapsibleValidationTests: ValidationCase {
    func testControlledCollapsibleRoutesBindingCallbackAndContent() {
        let app = launchHost(scene: "collapsible")
        let trigger = app.buttons["collapsible-controlled-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertEqual(trigger.value as? String, "Collapsed")
        XCTAssertFalse(app.staticTexts["collapsible-controlled-content"].exists)

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["collapsible-controlled-echo"]), "Controlled: open")
        XCTAssertEqual(text(of: app.staticTexts["collapsible-controlled-callback"]), "Controlled callback: open")
        XCTAssertTrue(app.staticTexts["collapsible-controlled-content"].waitForExistence(timeout: 2))
        XCTAssertEqual(trigger.value as? String, "Expanded")

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["collapsible-controlled-echo"]), "Controlled: closed")
        XCTAssertEqual(text(of: app.staticTexts["collapsible-controlled-callback"]), "Controlled callback: closed")
        XCTAssertTrue(app.staticTexts["collapsible-controlled-content"].waitForNonExistence(timeout: 2))
        attachWindowScreenshot(of: app, named: "collapsible-light")
    }

    func testDefaultOpenUncontrolledAndKeepMountedFormsRouteState() {
        let app = launchHost(scene: "collapsible")
        let trigger = app.buttons["collapsible-default-open-trigger"]
        let content = app.staticTexts["collapsible-default-open-content"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertEqual(trigger.value as? String, "Expanded")
        XCTAssertTrue(content.exists)

        trigger.click()
        XCTAssertEqual(trigger.value as? String, "Collapsed")
        XCTAssertEqual(text(of: app.staticTexts["collapsible-internal-callback"]), "Internal callback: closed")
        XCTAssertFalse(content.exists, "closed keep-mounted content must be hidden from accessibility")
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "collapsible")
        let trigger = app.buttons["collapsible-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "collapsible", appearance: "dark")
        XCTAssertTrue(app.buttons["collapsible-controlled-trigger"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "collapsible-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "collapsible", appearance: "light")
        XCTAssertTrue(app.buttons["collapsible-controlled-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "collapsible", appearance: "dark")
        XCTAssertTrue(app.buttons["collapsible-controlled-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
