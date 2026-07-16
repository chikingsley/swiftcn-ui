import XCTest

final class ToggleGroupValidationTests: ValidationCase {
    func testControlledSingleSelectionRoutesTypedValueAndCallback() {
        let app = launchHost(scene: "togglegroup")
        let left = app.buttons["togglegroup-single-left"]
        let center = app.buttons["togglegroup-single-center"]
        XCTAssertTrue(left.waitForExistence(timeout: 5))
        XCTAssertEqual(left.value as? String, "On")
        XCTAssertEqual(center.value as? String, "Off")

        center.click()
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-single-echo"]), "Single: center")
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-single-callback"]), "Single callback: center")
        XCTAssertEqual(left.value as? String, "Off")
        XCTAssertEqual(center.value as? String, "On")

        center.click()
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-single-echo"]), "Single: none")
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-single-callback"]), "Single callback: none")
        attachWindowScreenshot(of: app, named: "togglegroup-light")
    }

    func testControlledMultipleVerticalSelectionTogglesIndependently() {
        let app = launchHost(scene: "togglegroup")
        let bold = app.buttons["togglegroup-multiple-bold"]
        let italic = app.buttons["togglegroup-multiple-italic"]
        XCTAssertTrue(bold.waitForExistence(timeout: 5))
        XCTAssertEqual(bold.value as? String, "On")

        italic.click()
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-multiple-echo"]), "Multiple: bold,italic")
        XCTAssertEqual(
            text(of: app.staticTexts["togglegroup-multiple-callback"]),
            "Multiple callback: bold,italic"
        )
        bold.click()
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-multiple-echo"]), "Multiple: italic")
        XCTAssertEqual(italic.value as? String, "On")
    }

    func testInternalLargeGroupAndAllDisabledFormsRenderAndRoute() {
        let app = launchHost(scene: "togglegroup")
        let day = app.buttons["togglegroup-internal-day"]
        let week = app.buttons["togglegroup-internal-week"]
        XCTAssertTrue(day.waitForExistence(timeout: 5))
        XCTAssertEqual(week.value as? String, "On")
        day.click()
        XCTAssertEqual(text(of: app.staticTexts["togglegroup-internal-callback"]), "Internal callback: day")
        XCTAssertEqual(day.value as? String, "On")

        let disabledItem = app.buttons["togglegroup-disabled-item"]
        XCTAssertTrue(disabledItem.exists)
        XCTAssertFalse(disabledItem.isEnabled)

        let disabledRootItem = app.buttons["togglegroup-disabled-root-item"]
        XCTAssertTrue(disabledRootItem.exists)
        XCTAssertFalse(disabledRootItem.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "togglegroup", appearance: "dark")
        XCTAssertTrue(app.buttons["togglegroup-single-left"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "togglegroup-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "togglegroup", appearance: "light")
        XCTAssertTrue(app.buttons["togglegroup-single-left"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "togglegroup", appearance: "dark")
        XCTAssertTrue(app.buttons["togglegroup-single-left"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
