import XCTest

/// The scroller settles asynchronously (preference-key geometry round trips
/// plus a 0.25s easeOut animation), so assertions on its derived state poll
/// briefly instead of reading immediately after a click.
final class MessageScrollerValidationTests: ValidationCase {
    private func waitForText(_ element: XCUIElement, toEqual expected: String, timeout: TimeInterval = 5) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if text(of: element) == expected { return true }
            RunLoop.current.run(until: Date().addingTimeInterval(0.05))
        }
        return text(of: element) == expected
    }

    func testEveryTranscriptItemRenders() {
        let app = launchHost(scene: "messagescroller")
        XCTAssertTrue(app.scrollViews["messagescroller-root"].waitForExistence(timeout: 5))
        for index in 1...20 {
            XCTAssertTrue(
                app.groups["messagescroller-item-m\(index)"].exists,
                "message m\(index) is missing"
            )
        }
        attachWindowScreenshot(of: app, named: "messagescroller-light")
    }

    func testEndPositionExposesScrollableStartEdgeState() {
        let app = launchHost(scene: "messagescroller")
        let atEnd = app.staticTexts["messagescroller-atend-echo"]
        let canStart = app.staticTexts["messagescroller-canstart-echo"]
        let canEnd = app.staticTexts["messagescroller-canend-echo"]
        XCTAssertTrue(atEnd.waitForExistence(timeout: 5))

        // Drive real scrolls so the scroll-geometry observer recomputes the
        // edge flags: scroll to the start (a genuine end->top move), then back
        // to the end. At the end, with 20 messages in a 260pt viewport,
        // content extends above: AtEnd true, CanEnd false, CanStart true.
        app.buttons["messagescroller-command-start"].click()
        XCTAssertTrue(waitForText(canStart, toEqual: "CanStart: false"))
        app.buttons["messagescroller-command-end"].click()
        XCTAssertTrue(waitForText(atEnd, toEqual: "AtEnd: true"))
        XCTAssertTrue(waitForText(canEnd, toEqual: "CanEnd: false"))
        XCTAssertTrue(waitForText(canStart, toEqual: "CanStart: true"))
    }

    func testScrollToStartAndEndCommandsUpdateObservableEdgeState() {
        let app = launchHost(scene: "messagescroller")
        let atEnd = app.staticTexts["messagescroller-atend-echo"]
        let canStart = app.staticTexts["messagescroller-canstart-echo"]
        let canEnd = app.staticTexts["messagescroller-canend-echo"]
        XCTAssertTrue(atEnd.waitForExistence(timeout: 5))

        app.buttons["messagescroller-command-start"].click()
        XCTAssertTrue(waitForText(canStart, toEqual: "CanStart: false"), "scrollToStart must reach the top edge")
        XCTAssertTrue(waitForText(canEnd, toEqual: "CanEnd: true"))
        XCTAssertTrue(waitForText(atEnd, toEqual: "AtEnd: false"))

        app.buttons["messagescroller-command-end"].click()
        XCTAssertTrue(waitForText(atEnd, toEqual: "AtEnd: true"), "scrollToEnd must return to the live edge")
        XCTAssertTrue(waitForText(canEnd, toEqual: "CanEnd: false"))
    }

    func testScrollButtonsToggleAccessibilityWithEdgeState() {
        let app = launchHost(scene: "messagescroller")
        let canStart = app.staticTexts["messagescroller-canstart-echo"]
        XCTAssertTrue(canStart.waitForExistence(timeout: 5))
        // Drive a real scroll to the start then back to the end so the
        // scroll-geometry observer recomputes the flags deterministically.
        app.buttons["messagescroller-command-start"].click()
        XCTAssertTrue(waitForText(canStart, toEqual: "CanStart: false"))
        app.buttons["messagescroller-command-end"].click()
        XCTAssertTrue(waitForText(canStart, toEqual: "CanStart: true"))

        // At the live edge: the "scroll to start" control is active
        // (content extends above) and "scroll to end" is inert and hidden.
        XCTAssertTrue(app.buttons["messagescroller-scroll-start-button"].exists)
        XCTAssertFalse(
            app.buttons["messagescroller-scroll-end-button"].exists,
            "scroll-to-end control must be accessibilityHidden while already at the end"
        )

        app.buttons["messagescroller-command-start"].click()
        XCTAssertTrue(waitForText(canStart, toEqual: "CanStart: false"))
        XCTAssertTrue(app.buttons["messagescroller-scroll-end-button"].exists)
        XCTAssertFalse(
            app.buttons["messagescroller-scroll-start-button"].exists,
            "scroll-to-start control must be accessibilityHidden while already at the start"
        )
    }

    func testJumpToMessageUpdatesTheAnchorEcho() {
        let app = launchHost(scene: "messagescroller")
        let anchor = app.staticTexts["messagescroller-anchor-echo"]
        XCTAssertTrue(anchor.waitForExistence(timeout: 5))

        app.buttons["messagescroller-jump-m5"].click()
        XCTAssertTrue(
            waitForText(anchor, toEqual: "Anchor: m5", timeout: 8),
            "scrollToMessage(\"m5\") must settle m5 as the current anchor"
        )
    }

    func testDisabledCommandButtonIsExposedAsDisabled() {
        let app = launchHost(scene: "messagescroller")
        let button = app.buttons["messagescroller-disabled-command"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "messagescroller", appearance: "dark")
        XCTAssertTrue(app.scrollViews["messagescroller-root"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "messagescroller-dark")
    }

    // The transcript rests scrolled to its live edge, so earlier rows sit
    // above the viewport; the audit still samples their reported frames,
    // reading pixels outside the window (title bar / desktop), and reports a
    // meaningless contrast result. On-screen bubble contrast is audited for
    // real by the Bubble suite. Identifier-less, so matched by "".
    private var offscreenRowContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "messagescroller", appearance: "light")
        XCTAssertTrue(app.scrollViews["messagescroller-root"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: offscreenRowContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "messagescroller", appearance: "dark")
        XCTAssertTrue(app.scrollViews["messagescroller-root"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: offscreenRowContrastFindings)
    }
}
