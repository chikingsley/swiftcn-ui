import XCTest

final class ToggleValidationTests: ValidationCase {
    private let identifiers = [
        "toggle-default-sm", "toggle-default-default", "toggle-default-lg",
        "toggle-outline-sm", "toggle-outline-default", "toggle-outline-lg",
    ]

    func testEveryVariantAndSizeRendersWithPressedValues() {
        let app = launchHost(scene: "toggle")
        XCTAssertTrue(app.checkBoxes["toggle-default-default"].waitForExistence(timeout: 5))

        for identifier in identifiers {
            XCTAssertTrue(app.checkBoxes[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertEqual(app.checkBoxes["toggle-default-sm"].value as? Int, 0)
        XCTAssertEqual(app.checkBoxes["toggle-default-lg"].value as? Int, 1)
        XCTAssertEqual(app.checkBoxes["toggle-outline-default"].value as? Int, 1)
        attachWindowScreenshot(of: app, named: "toggle-light")
    }

    func testPressedBindingRoutesIntoCallerOwnedState() {
        let app = launchHost(scene: "toggle")
        let toggle = app.checkBoxes["toggle-default-default"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertEqual(toggle.value as? Int, 0)

        toggle.click()
        XCTAssertEqual(toggle.value as? Int, 1)
        XCTAssertEqual(text(of: app.staticTexts["toggle-pressed-echo"]), "Pressed: true")

        toggle.click()
        XCTAssertEqual(toggle.value as? Int, 0)
        XCTAssertEqual(text(of: app.staticTexts["toggle-pressed-echo"]), "Pressed: false")
    }

    func testDisabledToggleIsExposedAsDisabled() {
        let app = launchHost(scene: "toggle")
        let toggle = app.checkBoxes["toggle-disabled"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))
        XCTAssertFalse(toggle.isEnabled)
        XCTAssertEqual(toggle.value as? Int, 1)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "toggle", appearance: "dark")
        XCTAssertTrue(app.checkBoxes["toggle-default-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "toggle-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "toggle", appearance: "light")
        XCTAssertTrue(app.checkBoxes["toggle-default-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "toggle", appearance: "dark")
        XCTAssertTrue(app.checkBoxes["toggle-default-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
