import XCTest

final class TabsValidationTests: ValidationCase {
    func testDefaultHorizontalTabsRouteTypedSelectionAndPanels() {
        let app = launchHost(scene: "tabs")
        let account = app.buttons["tabs-default-account"]
        let password = app.buttons["tabs-default-password"]
        XCTAssertTrue(account.waitForExistence(timeout: 5))
        XCTAssertTrue(password.exists)
        XCTAssertEqual(account.value as? String, "Selected")
        XCTAssertTrue(app.staticTexts["tabs-account-panel"].exists)
        XCTAssertFalse(app.staticTexts["tabs-password-panel"].exists)

        password.click()
        XCTAssertEqual(text(of: app.staticTexts["tabs-horizontal-selection"]), "Horizontal: password")
        XCTAssertEqual(text(of: app.staticTexts["tabs-horizontal-callback"]), "Callback: password")
        XCTAssertEqual(password.value as? String, "Selected")
        XCTAssertFalse(app.staticTexts["tabs-account-panel"].exists)
        XCTAssertTrue(app.staticTexts["tabs-password-panel"].exists)
        attachWindowScreenshot(of: app, named: "tabs-light")
    }

    func testLineVerticalTabsRenderAndRouteOptionalSelection() {
        let app = launchHost(scene: "tabs")
        let account = app.buttons["tabs-line-account"]
        let password = app.buttons["tabs-line-password"]
        XCTAssertTrue(account.waitForExistence(timeout: 5))
        XCTAssertEqual(password.value as? String, "Selected")
        XCTAssertTrue(app.staticTexts["tabs-vertical-password-panel"].exists)

        account.click()
        XCTAssertEqual(text(of: app.staticTexts["tabs-vertical-selection"]), "Vertical: account")
        XCTAssertTrue(app.staticTexts["tabs-vertical-account-panel"].exists)
        XCTAssertFalse(app.staticTexts["tabs-vertical-password-panel"].exists)
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "tabs")
        let trigger = app.buttons["tabs-disabled-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
        XCTAssertEqual(trigger.value as? String, "Not selected")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "tabs", appearance: "dark")
        XCTAssertTrue(app.buttons["tabs-default-account"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "tabs-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "tabs", appearance: "light")
        XCTAssertTrue(app.buttons["tabs-default-account"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "tabs", appearance: "dark")
        XCTAssertTrue(app.buttons["tabs-default-account"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
