import XCTest

final class HoverCardValidationTests: ValidationCase {
    private let sides = ["top", "bottom", "leading", "trailing", "left", "right"]

    func testEverySidePresentsInAppKitPanelAndDismisses() {
        let app = launchHost(scene: "hovercard")
        XCTAssertTrue(app.buttons["hovercard-present-top"].waitForExistence(timeout: 5))

        for side in sides {
            app.buttons["hovercard-present-\(side)"].click()
            let panel = app.descendants(matching: .dialog).firstMatch
            XCTAssertTrue(panel.waitForExistence(timeout: 5), "\(side) hover card did not present")
            XCTAssertEqual(app.descendants(matching: .dialog).count, 1)
            XCTAssertEqual(
                text(
                    of: panel.staticTexts.matching(
                        NSPredicate(format: "value == %@", "Hover card details")
                    ).firstMatch
                ),
                "Hover card details"
            )
            XCTAssertEqual(
                text(
                    of: panel.staticTexts.matching(
                        NSPredicate(
                            format: "value == %@",
                            "An AppKit overlay panel anchored outside the host layout."
                        )
                    ).firstMatch
                ),
                "An AppKit overlay panel anchored outside the host layout."
            )

            // The non-key NSPanel is exposed as a sibling AXDialog rather
            // than an XCUI window. This preserves the intentional contract
            // that hover content does not steal keyboard focus.
            panel.buttons["Dismiss hover card"].click()
            XCTAssertTrue(panel.waitForNonExistence(timeout: 2), "\(side) hover card did not dismiss")
        }
    }

    func testActionInsidePanelRoutesIntoCallerState() {
        let app = launchHost(scene: "hovercard")
        app.buttons["hovercard-present-bottom"].click()
        let panel = app.descendants(matching: .dialog).firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        let initialCount = panel.staticTexts.matching(
            NSPredicate(format: "value == %@", "Actions: 0")
        ).firstMatch
        XCTAssertTrue(initialCount.exists)

        panel.buttons["Run hover-card action"].click()
        let updatedCount = panel.staticTexts.matching(
            NSPredicate(format: "value == %@", "Actions: 1")
        ).firstMatch
        XCTAssertTrue(updatedCount.waitForExistence(timeout: 2))
        panel.buttons["Dismiss hover card"].click()
        XCTAssertTrue(panel.waitForNonExistence(timeout: 2))
        XCTAssertEqual(text(of: app.staticTexts["hovercard-scene-action-count"]), "Actions: 1")
    }

    func testFocusOpenPathPresentsAndEscapeDismisses() {
        let app = launchHost(scene: "hovercard")
        let trigger = app.buttons["hovercard-focus-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let content = app.descendants(matching: .any)["hovercard-focus-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5), "keyboard focus did not open the card")
        // The card opening IS the observable proof the trigger took focus;
        // macOS XCUITest cannot query keyboard focus directly.
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "Escape did not dismiss the card")
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "hovercard")
        let trigger = app.buttons["hovercard-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testControlledClickDoesNotPretendToValidateHover() {
        let app = launchHost(scene: "hovercard")
        let trigger = app.buttons["hovercard-present-leading"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        XCTAssertTrue(
            app.descendants(matching: .any)["hovercard-leading-content"]
                .waitForExistence(timeout: 5)
        )

        // The click intentionally drives the public controlled binding. It
        // proves panel presentation but not AppKit pointer-enter timing;
        // hover-open, hover-transfer, and delayed hover-close remain manual
        // VALIDATION because XCUITest hover is not deterministic on macOS.
        XCTAssertEqual(
            text(of: app.staticTexts["hovercard-last-change"]),
            "Last change: none"
        )
    }

    func testLightAppearanceRendersPresentedHoverCard() {
        let app = launchHost(scene: "hovercard", appearance: "light")
        app.buttons["hovercard-present-bottom"].click()
        let panel = app.descendants(matching: .dialog).firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        XCTAssertTrue(
            panel.staticTexts.matching(
                NSPredicate(format: "value == %@", "Hover card details")
            ).firstMatch.exists)
        attachPanelScreenshot(panel, named: "hovercard-light")
    }

    func testDarkAppearanceRendersPresentedHoverCard() {
        let app = launchHost(scene: "hovercard", appearance: "dark")
        app.buttons["hovercard-present-bottom"].click()
        let panel = app.descendants(matching: .dialog).firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        XCTAssertTrue(
            panel.staticTexts.matching(
                NSPredicate(format: "value == %@", "Hover card details")
            ).firstMatch.exists)
        attachPanelScreenshot(panel, named: "hovercard-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "hovercard", appearance: "light")
        app.buttons["hovercard-present-bottom"].click()
        let panel = app.descendants(matching: .dialog).firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        assertPresentedHoverCardDescriptions(in: panel)

        // Apple's macOS description audit requires a label on the
        // system-owned non-key AXDialog even though all meaningful panel
        // descendants expose text and roles below. VoiceOver traversal of
        // that container remains manual VALIDATION; every other audit runs.
        try runAccessibilityAudit(on: app, excluding: .sufficientElementDescription)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "hovercard", appearance: "dark")
        app.buttons["hovercard-present-bottom"].click()
        let panel = app.descendants(matching: .dialog).firstMatch
        XCTAssertTrue(panel.waitForExistence(timeout: 5))
        assertPresentedHoverCardDescriptions(in: panel)

        // Same system-owned non-key AXDialog false positive as light mode;
        // explicit descendant checks cover description semantics, while
        // VoiceOver traversal remains manual VALIDATION.
        try runAccessibilityAudit(on: app, excluding: .sufficientElementDescription)
    }

    private func attachPanelScreenshot(_ panel: XCUIElement, named name: String) {
        let attachment = XCTAttachment(screenshot: panel.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func assertPresentedHoverCardDescriptions(in panel: XCUIElement) {
        XCTAssertEqual(
            text(
                of: panel.staticTexts.matching(
                    NSPredicate(format: "value == %@", "Hover card details")
                ).firstMatch
            ),
            "Hover card details"
        )
        XCTAssertEqual(
            text(
                of: panel.staticTexts.matching(
                    NSPredicate(
                        format: "value == %@",
                        "An AppKit overlay panel anchored outside the host layout."
                    )
                ).firstMatch
            ),
            "An AppKit overlay panel anchored outside the host layout."
        )
        XCTAssertEqual(panel.buttons["Run hover-card action"].label, "Run hover-card action")
        XCTAssertEqual(panel.buttons["Dismiss hover card"].label, "Dismiss hover card")
    }
}
