import XCTest

final class SheetValidationTests: ValidationCase {
    private let edges = ["top", "bottom", "leading", "trailing"]

    func testEveryEdgePresentsHeaderFooterAndComposedClose() {
        let app = launchHost(scene: "sheet")
        XCTAssertTrue(app.buttons["sheet-present-top"].waitForExistence(timeout: 5))

        for edge in edges {
            app.buttons["sheet-present-\(edge)"].click()
            let content = app.descendants(matching: .any)["sheet-\(edge)-content"]
            XCTAssertTrue(content.waitForExistence(timeout: 5), "\(edge) sheet did not present")
            XCTAssertTrue(app.staticTexts["sheet-title"].exists)
            XCTAssertTrue(app.staticTexts["sheet-description"].exists)
            XCTAssertEqual(text(of: app.staticTexts["sheet-edge-echo"]), "Edge: \(edge)")

            app.buttons["sheet-composed-close"].click()
            XCTAssertTrue(content.waitForNonExistence(timeout: 2), "\(edge) sheet did not dismiss")
        }
    }

    func testActionInsideSheetRoutesIntoCallerState() {
        let app = launchHost(scene: "sheet")
        app.buttons["sheet-present-trailing"].click()
        let count = app.staticTexts["sheet-action-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["sheet-run-action"].click()
        XCTAssertEqual(text(of: count), "Actions: 1")
        app.buttons["sheet-composed-close"].click()
        XCTAssertEqual(text(of: app.staticTexts["sheet-scene-action-count"]), "Actions: 1")
    }

    func testAutomaticCloseAndEscapeBothDismiss() {
        let app = launchHost(scene: "sheet")
        let trigger = app.buttons["sheet-present-automatic"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        let content = app.descendants(matching: .any)["sheet-trailing-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        app.buttons["Close"].click()
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "automatic close did not dismiss")

        trigger.click()
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "Escape did not dismiss")
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "sheet")
        let trigger = app.buttons["sheet-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testLightAppearanceRendersPresentedSheet() {
        let app = launchHost(scene: "sheet", appearance: "light")
        app.buttons["sheet-present-trailing"].click()
        XCTAssertTrue(app.staticTexts["sheet-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "sheet-light")
    }

    func testDarkAppearanceRendersPresentedSheet() {
        let app = launchHost(scene: "sheet", appearance: "dark")
        app.buttons["sheet-present-trailing"].click()
        XCTAssertTrue(app.staticTexts["sheet-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "sheet-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "sheet", appearance: "light")
        app.buttons["sheet-present-trailing"].click()
        XCTAssertTrue(app.staticTexts["sheet-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "sheet", appearance: "dark")
        app.buttons["sheet-present-trailing"].click()
        XCTAssertTrue(app.staticTexts["sheet-title"].waitForExistence(timeout: 5))
        // False positive: the description is theme.mutedForeground (zinc-400
        // #9F9FA9) on the panel's opaque theme.background (zinc-950 #09090B) =
        // 7.59:1, well above WCAG AA 4.5:1. Apple's dark sampler catches the
        // panel-edge/scrim behind the text; light mode (7.72:1) does not flag.
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(descriptionContains: "Contrast", identifier: "sheet-description")
            ]
        )
    }
}
