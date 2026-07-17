import XCTest

final class AlertDialogValidationTests: ValidationCase {
    private let sizes = ["default", "small"]

    func testEverySizePresentsSemanticContentAndDismissesViaCancel() {
        let app = launchHost(scene: "alertdialog")
        XCTAssertTrue(app.buttons["alertdialog-present-default"].waitForExistence(timeout: 5))

        for size in sizes {
            let trigger = app.buttons["alertdialog-present-\(size)"]
            XCTAssertTrue(trigger.exists, "\(size) trigger is missing")
            trigger.click()

            let content = app.descendants(matching: .any)["alertdialog-\(size)-content"]
            XCTAssertTrue(content.waitForExistence(timeout: 5), "\(size) content did not present")
            XCTAssertTrue(app.staticTexts["alertdialog-title"].exists)
            XCTAssertTrue(app.staticTexts["alertdialog-description"].exists)

            app.buttons["alertdialog-cancel"].click()
            XCTAssertTrue(content.waitForNonExistence(timeout: 2), "\(size) content did not dismiss via cancel")
        }
        XCTAssertEqual(text(of: app.staticTexts["alertdialog-cancel-count"]), "Cancels: \(sizes.count)")
    }

    func testActionsInsideAlertDialogRouteIntoCallerStateAndDismiss() {
        let app = launchHost(scene: "alertdialog")
        app.buttons["alertdialog-present-default"].click()
        let content = app.descendants(matching: .any)["alertdialog-default-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        // Every SCAlertDialogAction dismisses before invoking its closure
        // (AlertDialog.swift:293-302), so one click must both close the
        // surface and route the action into caller-owned state.
        app.buttons["alertdialog-save"].click()
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "save must dismiss like every alert dialog action")
        XCTAssertEqual(text(of: app.staticTexts["alertdialog-scene-save-count"]), "Saves: 1")

        app.buttons["alertdialog-present-default"].click()
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.buttons["alertdialog-delete"].click()
        XCTAssertTrue(content.waitForNonExistence(timeout: 2))
        XCTAssertEqual(text(of: app.staticTexts["alertdialog-scene-delete-count"]), "Deletes: 1")
    }

    func testDisabledActionIsExposedAsDisabled() {
        let app = launchHost(scene: "alertdialog")
        app.buttons["alertdialog-present-default"].click()
        let disabledAction = app.buttons["alertdialog-action-disabled"]
        XCTAssertTrue(disabledAction.waitForExistence(timeout: 5))
        XCTAssertFalse(disabledAction.isEnabled)
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "alertdialog")
        let trigger = app.buttons["alertdialog-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testBackdropDoesNotDismissTheAlertDialog() {
        let app = launchHost(scene: "alertdialog")
        app.buttons["alertdialog-present-default"].click()
        let content = app.descendants(matching: .any)["alertdialog-default-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        // Alert dialogs demand an explicit decision: SCAlertDialogOverlay
        // carries no dismiss gesture (AlertDialog.swift:116-125), unlike
        // SCDialog's backdrop. A corner click must leave the surface
        // presented.
        app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.05, dy: 0.9)).click()
        XCTAssertTrue(content.exists, "backdrop click must not dismiss an alert dialog")
    }

    func testEscapeDismissesTheAlertDialog() {
        let app = launchHost(scene: "alertdialog")
        let trigger = app.buttons["alertdialog-present-default"]
        trigger.click()
        let content = app.descendants(matching: .any)["alertdialog-default-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        // Upstream Radix/shadcn AlertDialog dismisses on Escape even though
        // its backdrop is non-dismissible — only the overlay's pointer
        // dismissal is suppressed. AlertDialog.swift has no
        // onKeyPress(.escape)/onExitCommand handler at all (contrast
        // Dialog.swift:257-264), so this is expected to fail until that
        // parity gap is closed; it is a real finding, not a flaky assertion.
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "Escape must dismiss an alert dialog")
    }

    func testLightAndDarkAppearancesRenderPresentedContent() {
        let lightApp = launchHost(scene: "alertdialog", appearance: "light")
        lightApp.buttons["alertdialog-present-default"].click()
        XCTAssertTrue(lightApp.staticTexts["alertdialog-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: lightApp, named: "alertdialog-light")

        let darkApp = launchHost(scene: "alertdialog", appearance: "dark")
        darkApp.buttons["alertdialog-present-default"].click()
        XCTAssertTrue(darkApp.staticTexts["alertdialog-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: darkApp, named: "alertdialog-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "alertdialog", appearance: "light")
        app.buttons["alertdialog-present-default"].click()
        XCTAssertTrue(app.staticTexts["alertdialog-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "alertdialog", appearance: "dark")
        app.buttons["alertdialog-present-default"].click()
        XCTAssertTrue(app.staticTexts["alertdialog-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
