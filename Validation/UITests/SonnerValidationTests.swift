import XCTest

/// SCSonner has no rendering surface of its own — it is a typed facade over
/// the shared SCToastCenter/SCToastStack that Toast also uses (see the
/// scene's doc comment). These tests drive that facade's real dispatch
/// calls and observe the shared queue's actual presentation, since toast
/// cards expose no caller-attachable accessibility identifiers: assertions
/// match rendered title/description text instead.
final class SonnerValidationTests: ValidationCase {
    func testShowPresentsTitleAndDescriptionAndCloseButtonDismissesIt() {
        let app = launchHost(scene: "sonner")
        let show = app.buttons["sonner-show-default"]
        XCTAssertTrue(show.waitForExistence(timeout: 5))
        show.click()

        let title = app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
        XCTAssertTrue(title.firstMatch.waitForExistence(timeout: 5), "toast title did not present")
        XCTAssertTrue(
            app.staticTexts.matching(
                NSPredicate(format: "value == %@", "Monday, January 3rd at 6:00pm")
            ).firstMatch.exists
        )
        attachWindowScreenshot(of: app, named: "sonner-light")

        app.buttons["Dismiss notification"].click()
        XCTAssertTrue(title.firstMatch.waitForNonExistence(timeout: 2), "close button did not dismiss the toast")
    }

    func testActionButtonRunsItsHandlerAndDismissesTheToast() {
        let app = launchHost(scene: "sonner")
        app.buttons["sonner-show-action"].click()
        let title = app.staticTexts.matching(NSPredicate(format: "value == %@", "Message archived"))
        XCTAssertTrue(title.firstMatch.waitForExistence(timeout: 5))

        app.buttons["Undo"].click()
        XCTAssertEqual(text(of: app.staticTexts["sonner-action-runs"]), "Action runs: 1")
        XCTAssertTrue(title.firstMatch.waitForNonExistence(timeout: 2), "running the action must dismiss the toast")
    }

    func testLoadingUpdatesInPlaceRatherThanQueuingASecondToast() {
        let app = launchHost(scene: "sonner")
        app.buttons["sonner-show-loading"].click()
        let loadingTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Uploading…"))
        XCTAssertTrue(loadingTitle.firstMatch.waitForExistence(timeout: 5))

        app.buttons["sonner-update-loading"].click()
        let updatedTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Uploaded"))
        XCTAssertTrue(updatedTitle.firstMatch.waitForExistence(timeout: 5))
        XCTAssertFalse(loadingTitle.firstMatch.exists, "update must replace the loading toast, not add a second one")
    }

    func testExplicitDurationAutoDismissesWithoutManualAction() {
        let app = launchHost(scene: "sonner")
        app.buttons["sonner-show-auto"].click()
        let title = app.staticTexts.matching(NSPredicate(format: "value == %@", "Ephemeral"))
        XCTAssertTrue(title.firstMatch.waitForExistence(timeout: 5))
        // Toasts pause their timer while hovered; park the pointer on the
        // title bar so the dispatch click's pointer position cannot pause the
        // countdown, and allow the exit transition its time.
        app.windows.firstMatch.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01)).hover()
        XCTAssertTrue(title.firstMatch.waitForNonExistence(timeout: 8), "a 1s duration toast must auto-dismiss")
    }

    func testDismissRemovesExactlyTheRequestedToast() {
        let app = launchHost(scene: "sonner")
        app.buttons["sonner-show-default"].click()
        app.buttons["sonner-show-success"].click()
        let defaultTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
        let successTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Saved"))
        XCTAssertTrue(defaultTitle.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(successTitle.firstMatch.exists)

        app.buttons["sonner-dismiss-success"].click()
        XCTAssertTrue(successTitle.firstMatch.waitForNonExistence(timeout: 2))
        XCTAssertTrue(defaultTitle.firstMatch.exists, "dismissing one id must not remove the other queued toast")
    }

    func testDismissAllClearsEveryQueuedToast() {
        let app = launchHost(scene: "sonner")
        app.buttons["sonner-show-default"].click()
        app.buttons["sonner-show-success"].click()
        let defaultTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
        let successTitle = app.staticTexts.matching(NSPredicate(format: "value == %@", "Saved"))
        XCTAssertTrue(defaultTitle.firstMatch.waitForExistence(timeout: 5))

        app.buttons["sonner-dismiss-all"].click()
        XCTAssertTrue(defaultTitle.firstMatch.waitForNonExistence(timeout: 2))
        XCTAssertTrue(successTitle.firstMatch.waitForNonExistence(timeout: 2))
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "sonner")
        let button = app.buttons["sonner-show-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "sonner", appearance: "dark")
        app.buttons["sonner-show-default"].click()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
                .firstMatch.waitForExistence(timeout: 5)
        )
        attachWindowScreenshot(of: app, named: "sonner-dark")
    }

    // The sampler flags the 13px muted toast description: mutedForeground on
    // the popover surface computes to 7.72:1 (light) — clearing WCAG AA text
    // (4.5:1). Identifier-less, so matched by "".
    private var mutedDescriptionContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "sonner", appearance: "light")
        app.buttons["sonner-show-default"].click()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
                .firstMatch.waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(on: app, tolerating: mutedDescriptionContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "sonner", appearance: "dark")
        app.buttons["sonner-show-default"].click()
        XCTAssertTrue(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Event has been created"))
                .firstMatch.waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(on: app, tolerating: mutedDescriptionContrastFindings)
    }
}
