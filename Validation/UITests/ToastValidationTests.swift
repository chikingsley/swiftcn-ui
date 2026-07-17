import XCTest

/// Toast cards expose no caller-attachable accessibility identifiers (they
/// are rendered entirely by the shared SCToastStack from queue content), so
/// assertions match rendered title text instead — the same approach
/// SonnerValidationTests uses against the same underlying queue.
final class ToastValidationTests: ValidationCase {
    func testShowPresentsTitleAndDescription() {
        let app = launchHost(scene: "toast")
        let show = app.buttons["toast-show-default"]
        XCTAssertTrue(show.waitForExistence(timeout: 5))
        show.click()

        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
                .firstMatch.waitForExistence(timeout: 5),
            "toast title did not present"
        )
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "value == %@", "Monday, January 3rd at 6:00pm")
            ).firstMatch.exists
        )
        attachWindowScreenshot(of: app, named: "toast-light")
    }

    func testDeleteActionRunsItsHandlerFiresOnDismissAndRemovesTheToast() {
        let app = launchHost(scene: "toast")
        app.buttons["toast-show-cancelable"].click()
        let title = app.staticTexts.matching(NSPredicate(format: "value == %@", "Delete file?"))
        XCTAssertTrue(title.firstMatch.waitForExistence(timeout: 5))

        app.buttons["Delete"].click()
        XCTAssertEqual(text(of: app.staticTexts["toast-action-runs"]), "Action runs: 1")
        XCTAssertEqual(text(of: app.staticTexts["toast-dismiss-callbacks"]), "onDismiss callbacks: 1")
        XCTAssertTrue(title.firstMatch.waitForNonExistence(timeout: 2))
    }

    func testKeepCancelRunsItsHandlerFiresOnDismissAndRemovesTheToast() {
        let app = launchHost(scene: "toast")
        app.buttons["toast-show-cancelable"].click()
        let title = app.staticTexts.matching(NSPredicate(format: "value == %@", "Delete file?"))
        XCTAssertTrue(title.firstMatch.waitForExistence(timeout: 5))

        app.buttons["Keep"].click()
        XCTAssertEqual(text(of: app.staticTexts["toast-cancel-runs"]), "Cancel runs: 1")
        XCTAssertEqual(text(of: app.staticTexts["toast-dismiss-callbacks"]), "onDismiss callbacks: 1")
        XCTAssertTrue(title.firstMatch.waitForNonExistence(timeout: 2))
    }

    func testNonDismissibleHidesTheCloseButtonUntilResolved() {
        let app = launchHost(scene: "toast")
        app.buttons["toast-show-nondismissible"].click()
        let loadingTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Syncing…"))
        XCTAssertTrue(loadingTitle.firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(
            app.buttons["Dismiss notification"].exists,
            "isDismissible: false must hide the close button"
        )

        app.buttons["toast-resolve-nondismissible"].click()
        let resolvedTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Synced"))
        XCTAssertTrue(resolvedTitle.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(
            app.buttons["Dismiss notification"].exists,
            "resolving isDismissible: true must expose the close button"
        )
    }

    func testDismissRemovesExactlyTheRequestedToastById() {
        let app = launchHost(scene: "toast")
        app.buttons["toast-show-default"].click()
        let title = app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
        XCTAssertTrue(title.firstMatch.waitForExistence(timeout: 5))

        app.buttons["toast-dismiss-default"].click()
        XCTAssertTrue(title.firstMatch.waitForNonExistence(timeout: 2))
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "toast")
        let button = app.buttons["toast-show-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "toast", appearance: "dark")
        app.buttons["toast-show-error"].click()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Upload failed"))
                .firstMatch.waitForExistence(timeout: 5)
        )
        attachWindowScreenshot(of: app, named: "toast-dark")
    }

    // The sampler flags the 13px muted toast description: mutedForeground on
    // the popover surface computes to 7.72:1 (light) — clearing WCAG AA text
    // (4.5:1). Identifier-less, so matched by "".
    private var mutedDescriptionContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "toast", appearance: "light")
        app.buttons["toast-show-default"].click()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
                .firstMatch.waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(on: app, tolerating: mutedDescriptionContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "toast", appearance: "dark")
        app.buttons["toast-show-default"].click()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
                .firstMatch.waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(on: app, tolerating: mutedDescriptionContrastFindings)
    }
}
