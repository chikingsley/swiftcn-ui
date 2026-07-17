import XCTest

final class NavigationMenuValidationTests: ValidationCase {
    func testTriggerOpensNativePopoverAndRoutesTheControlledValue() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        let trigger = app.buttons["navigationmenu-trigger-getting-started"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertEqual(trigger.value as? String, "Collapsed")

        // The trigger opens on a real 50ms hover timer and TOGGLES on click,
        // so a synthesized click races its own pointer-arrival hover (the
        // hover opens, the click closes). Hover-open and hover-out-close are
        // the deterministic automated contract; they drive the same
        // controlled binding in both directions.
        openByHover(trigger)
        let content = app.descendants(matching: .any)["navigationmenu-getting-started-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        XCTAssertEqual(app.descendants(matching: .popover).count, 1, "must expose a native AXPopover")
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-open-item"]), "Open item: getting-started")

        // Hover-out schedules the close through the same controlled binding,
        // proving it is genuinely bidirectional rather than latching.
        parkPointer(in: app)
        XCTAssertTrue(content.waitForNonExistence(timeout: 5))
        XCTAssertTrue(
            waitForValue("Collapsed", of: trigger, timeout: 5),
            "trigger did not finish collapsing"
        )
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-open-item"]), "Open item: none")
    }

    func testActionInsidePopoverRoutesIntoCallerStateAndClosesTheMenu() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        openByHover(app.buttons["navigationmenu-trigger-getting-started"])
        let content = app.descendants(matching: .any)["navigationmenu-getting-started-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        app.buttons["navigationmenu-action-introduction"].click()
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "an action with closesMenu: true must dismiss")
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-action-count"]), "Actions: 1")
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-last-action"]), "Last action: Introduction")
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-open-item"]), "Open item: none")
    }

    func testDisabledActionInsidePopoverIsExposedAsDisabled() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        openByHover(app.buttons["navigationmenu-trigger-getting-started"])
        let disabledAction = app.buttons["navigationmenu-action-disabled"]
        XCTAssertTrue(disabledAction.waitForExistence(timeout: 5))
        XCTAssertFalse(disabledAction.isEnabled)
    }

    func testActiveActionExposesSelectedTraitAndStillRoutesItsAction() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        openByHover(app.buttons["navigationmenu-trigger-components"])
        let activeAction = app.descendants(matching: .any)["navigationmenu-action-active"]
        XCTAssertTrue(activeAction.waitForExistence(timeout: 5))
        XCTAssertTrue(activeAction.isSelected, "isActive: true must surface as the selected accessibility trait")

        activeAction.click()
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-last-action"]), "Last action: Tabs")
    }

    func testLinkRoutesThroughInterceptedOpenURLAndClosesTheMenu() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        openByHover(app.buttons["navigationmenu-trigger-getting-started"])
        let link = app.descendants(matching: .any)["navigationmenu-link"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))

        // The scene overrides \.openURL at its root so this click never
        // launches a real browser; it only proves SCNavigationMenuLink
        // forwards the tap and closes the menu (NavigationMenu.swift's
        // closeAfterActivation via the overridden OpenURLAction).
        link.click()
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-url-open-count"]), "URLs opened: 1")
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-open-item"]), "Open item: none")
    }

    func testTriggerPresentationActionRoutesWithoutOpeningAPopover() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        let documentation = app.buttons["navigationmenu-trigger-documentation"]
        XCTAssertTrue(documentation.waitForExistence(timeout: 5))
        documentation.click()

        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-last-action"]), "Last action: Documentation")
        XCTAssertEqual(
            app.descendants(matching: .popover).count, 0,
            "an item with no content must never present a popover"
        )
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        let trigger = app.buttons["navigationmenu-trigger-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testEscapeDismissesTheOpenPopover() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        let trigger = app.buttons["navigationmenu-trigger-getting-started"]
        openByHover(trigger)
        let content = app.descendants(matching: .any)["navigationmenu-getting-started-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        // Move the pointer into the presented content first: hovering the
        // trigger while Escape dismisses would immediately re-open the menu.
        content.hover()

        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "Escape must dismiss the open popover")
        XCTAssertEqual(text(of: app.staticTexts["navigationmenu-open-item"]), "Open item: none")
    }

    func testArrowKeyTraversalRemainsManualValidation() {
        let app = launchHost(scene: "navigationmenu")
        parkPointer(in: app)
        XCTAssertTrue(app.buttons["navigationmenu-trigger-components"].waitForExistence(timeout: 5))
        // SCNavigationMenuList's arrow-key moveFocus drives open-on-down and
        // close-on-up between triggers via @FocusState, which this harness
        // cannot assert independently of a click; it remains manual
        // VoiceOver/keyboard VALIDATION. Hover-driven open/close and
        // click-driven toggling are the component's real pointer contract —
        // the suite automates the hover path (open on hover, close on
        // hover-out) because a synthesized click races the trigger's own
        // 50ms hover-open timer.
        print("SC-MANUAL-VALIDATION: arrow-key trigger traversal for navigationmenu-*")
    }

    func testLightAndDarkAppearancesRenderPresentedContent() {
        let lightApp = launchHost(scene: "navigationmenu", appearance: "light")
        parkPointer(in: lightApp)
        lightApp.buttons["navigationmenu-trigger-getting-started"].click()
        XCTAssertTrue(
            lightApp.descendants(matching: .any)["navigationmenu-getting-started-content"]
                .waitForExistence(timeout: 5)
        )
        attachWindowScreenshot(of: lightApp, named: "navigationmenu-light")
        // Close the popover before the relaunch: it overlaps the trigger row,
        // and a live popover at teardown makes the next hit-test resolve into
        // a stale AX element.
        lightApp.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])

        let darkApp = launchHost(scene: "navigationmenu", appearance: "dark")
        parkPointer(in: darkApp)
        darkApp.buttons["navigationmenu-trigger-getting-started"].click()
        XCTAssertTrue(
            darkApp.descendants(matching: .any)["navigationmenu-getting-started-content"]
                .waitForExistence(timeout: 5)
        )
        attachWindowScreenshot(of: darkApp, named: "navigationmenu-dark")
    }

    // The sampler flags the scene's echo texts where they meet the title-bar
    // boundary: plain foreground on the scene background computes to 17.9:1
    // (light) / 16.9:1 (dark) — nowhere near a real WCAG failure; the sample
    // row straddles window chrome. Matched by the echo identifiers.
    private var chromeBoundaryContrastFindings: [KnownAuditFinding] {
        [
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "navigationmenu-open-item"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "navigationmenu-action-count"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "navigationmenu-last-action"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "navigationmenu-url-open-count"),
        ]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "navigationmenu", appearance: "light")
        parkPointer(in: app)
        openByHover(app.buttons["navigationmenu-trigger-getting-started"])
        XCTAssertTrue(
            app.descendants(matching: .any)["navigationmenu-getting-started-content"].waitForExistence(timeout: 5)
        )
        // Same system-owned AXPopover false positive documented in
        // PopoverValidationTests: the native popover container is flagged
        // as undescribed even though every meaningful descendant below
        // exposes its own role and text.
        try runAccessibilityAudit(
            on: app, tolerating: chromeBoundaryContrastFindings, excluding: .sufficientElementDescription)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "navigationmenu", appearance: "dark")
        parkPointer(in: app)
        openByHover(app.buttons["navigationmenu-trigger-getting-started"])
        XCTAssertTrue(
            app.descendants(matching: .any)["navigationmenu-getting-started-content"].waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(
            on: app, tolerating: chromeBoundaryContrastFindings, excluding: .sufficientElementDescription)
    }

    private func waitForValue(
        _ value: String,
        of element: XCUIElement,
        timeout: TimeInterval
    ) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    /// SCNavigationMenuTrigger opens on hover (a real 50ms timer), so a
    /// pointer parked over the trigger row by an earlier interaction opens
    /// the menu before the test's first assertion. Park it on the window
    /// title bar first.
    private func parkPointer(in app: XCUIApplication) {
        app.windows.firstMatch.coordinate(
            withNormalizedOffset: CGVector(dx: 0.5, dy: 0.01)
        ).hover()
        Thread.sleep(forTimeInterval: 0.3)
    }

    /// Opens a hover-driven trigger deterministically: hover and wait for the
    /// controlled value to flip (the 50ms open timer makes click-opening a
    /// race against the click's own pointer-arrival hover).
    private func openByHover(_ trigger: XCUIElement) {
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.hover()
        XCTAssertTrue(
            waitForValue("Expanded", of: trigger, timeout: 5),
            "hovering the trigger did not open its content"
        )
    }
}
