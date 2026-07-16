import XCTest

final class EmptyValidationTests: ValidationCase {
    func testEveryRegionMediaTreatmentAndConvenienceRenders() {
        let app = launchHost(scene: "empty")
        XCTAssertTrue(app.staticTexts["empty-title"].waitForExistence(timeout: 5))

        for identifier in ["empty-arbitrary-content", "empty-title", "empty-description"] {
            XCTAssertTrue(app.staticTexts[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertTrue(app.images["empty-media-default"].exists)
        XCTAssertEqual(app.images["empty-media-default"].label, "Empty tray artwork")
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "empty-media-decorative").count,
            0,
            "decorative media must be hidden from accessibility"
        )
        XCTAssertTrue(app.groups["empty-composed"].exists)
        XCTAssertTrue(app.groups["empty-compact"].exists)
        XCTAssertTrue(app.buttons["empty-clear-button"].exists)
        attachWindowScreenshot(of: app, named: "empty-light")
    }

    func testActionsRouteToCallerOwnedState() {
        let app = launchHost(scene: "empty")
        let count = app.staticTexts["empty-activation-count"]
        let last = app.staticTexts["empty-last-activated"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["empty-create-button"].click()
        XCTAssertEqual(text(of: last), "Last: create")
        app.buttons["empty-import-button"].click()
        XCTAssertEqual(text(of: last), "Last: import")
        app.buttons["empty-clear-button"].click()
        XCTAssertEqual(text(of: last), "Last: clear")
        XCTAssertEqual(text(of: count), "Activations: 3")
    }

    func testDisabledActionIsExposedAsDisabled() {
        let app = launchHost(scene: "empty")
        let button = app.buttons["empty-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "empty", appearance: "dark")
        XCTAssertTrue(app.staticTexts["empty-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "empty-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "empty", appearance: "light")
        XCTAssertTrue(app.staticTexts["empty-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "empty", appearance: "dark")
        XCTAssertTrue(app.staticTexts["empty-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
