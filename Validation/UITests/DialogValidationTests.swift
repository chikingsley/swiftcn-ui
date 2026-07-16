import XCTest

final class DialogValidationTests: ValidationCase {
    private let sizes = ["default", "small", "large"]

    func testEverySizePresentsSemanticContentAndDismisses() {
        let app = launchHost(scene: "dialog")
        XCTAssertTrue(app.buttons["dialog-present-default"].waitForExistence(timeout: 5))

        for size in sizes {
            let trigger = app.buttons["dialog-present-\(size)"]
            XCTAssertTrue(trigger.exists, "\(size) trigger is missing")
            trigger.click()

            let content = app.descendants(matching: .any)["dialog-\(size)-content"]
            XCTAssertTrue(content.waitForExistence(timeout: 5), "\(size) content did not present")
            XCTAssertTrue(app.staticTexts["dialog-title"].exists)
            XCTAssertTrue(app.staticTexts["dialog-description"].exists)
            // Initial focus lands on the dialog surface; macOS XCUITest
            // cannot query keyboard focus (hasKeyboardFocus is iOS-only), so
            // focus entry stays a manual VoiceOver item. Presentation and
            // dismissal below are the drivable contract.

            app.buttons["dialog-dismiss"].click()
            XCTAssertTrue(content.waitForNonExistence(timeout: 2), "\(size) content did not dismiss")
        }
    }

    func testActionInsideDialogRoutesIntoCallerState() {
        let app = launchHost(scene: "dialog")
        app.buttons["dialog-present-default"].click()
        let count = app.staticTexts["dialog-action-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["dialog-run-action"].click()
        XCTAssertEqual(text(of: count), "Actions: 1")
        app.buttons["dialog-dismiss"].click()
        XCTAssertEqual(text(of: app.staticTexts["dialog-scene-action-count"]), "Actions: 1")
    }

    func testEscapeDismissesAndRestoresTheTrigger() {
        let app = launchHost(scene: "dialog")
        let trigger = app.buttons["dialog-present-default"]
        trigger.click()
        let content = app.descendants(matching: .any)["dialog-default-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        XCTAssertTrue(content.waitForNonExistence(timeout: 2))
        // Focus restoration to the trigger is a real contract but not
        // queryable in macOS XCUITest; it remains a manual VoiceOver item.
        XCTAssertEqual(text(of: app.staticTexts["dialog-presented-echo"]), "Presented: false")
    }

    func testBackdropDismissesTheDialog() {
        let app = launchHost(scene: "dialog")
        app.buttons["dialog-present-large"].click()
        let content = app.descendants(matching: .any)["dialog-large-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.9)).click()
        XCTAssertTrue(content.waitForNonExistence(timeout: 2))
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "dialog")
        let trigger = app.buttons["dialog-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testLightAndDarkAppearancesRenderPresentedContent() {
        let lightApp = launchHost(scene: "dialog", appearance: "light")
        lightApp.buttons["dialog-present-default"].click()
        XCTAssertTrue(lightApp.staticTexts["dialog-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: lightApp, named: "dialog-light")

        let darkApp = launchHost(scene: "dialog", appearance: "dark")
        darkApp.buttons["dialog-present-default"].click()
        XCTAssertTrue(darkApp.staticTexts["dialog-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: darkApp, named: "dialog-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "dialog", appearance: "light")
        app.buttons["dialog-present-default"].click()
        XCTAssertTrue(app.staticTexts["dialog-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "dialog", appearance: "dark")
        app.buttons["dialog-present-default"].click()
        XCTAssertTrue(app.staticTexts["dialog-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
