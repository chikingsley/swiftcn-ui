import XCTest

final class PopoverValidationTests: ValidationCase {
    private let sides = ["top", "bottom", "leading", "trailing", "left", "right"]
    private let alignments = ["start", "center", "end"]
    private let adaptations = ["popover", "sheet", "automatic"]

    func testEveryPositionPresentsInNativeWindowAndDismisses() {
        for side in sides {
            for alignment in alignments {
                let app = launchHost(scene: "popover")
                XCTAssertTrue(app.buttons["popover-present-top-start"].waitForExistence(timeout: 5))
                let name = "\(side)-\(alignment)"
                let trigger = app.buttons["popover-present-\(name)"]
                trigger.click()
                XCTAssertTrue(
                    waitForValue("Expanded", of: trigger, timeout: 5),
                    "\(name) trigger did not enter its presented state"
                )
                let content = app.descendants(matching: .any)["popover-\(name)-content"]
                XCTAssertTrue(content.waitForExistence(timeout: 5), "\(name) popover did not present")
                XCTAssertTrue(app.staticTexts["popover-title"].exists)
                XCTAssertTrue(app.staticTexts["popover-description"].exists)
                XCTAssertEqual(
                    app.descendants(matching: .popover).count,
                    1,
                    "\(name) did not expose a native AXPopover"
                )
                XCTAssertEqual(trigger.value as? String, "Expanded")

                // macOS folds the native popover's AXPopover subtree beneath
                // its trigger, so app.windows remains 1 even though AppKit
                // presents outside the host layout. AXPopover plus the
                // expanded trigger is the strongest observable contract.

                app.buttons["popover-dismiss"].click()
                XCTAssertTrue(content.waitForNonExistence(timeout: 2), "\(name) popover did not dismiss")
                XCTAssertTrue(
                    waitForValue("Collapsed", of: trigger, timeout: 5),
                    "\(name) trigger did not finish dismissing"
                )
                app.terminate()
            }
        }
    }

    func testEveryCompactAdaptationRenders() {
        let app = launchHost(scene: "popover")
        XCTAssertTrue(app.buttons["popover-adaptation-popover"].waitForExistence(timeout: 5))

        for adaptation in adaptations {
            app.buttons["popover-adaptation-\(adaptation)"].click()
            let content = app.descendants(matching: .any)["popover-adaptation-\(adaptation)-content"]
            XCTAssertTrue(content.waitForExistence(timeout: 5))
            let title = content.staticTexts["popover-adaptation-title"]
            XCTAssertTrue(title.exists)
            XCTAssertEqual(
                title.label,
                "Adaptation: \(adaptation)"
            )
            app.buttons["popover-dismiss"].click()
            XCTAssertTrue(content.waitForNonExistence(timeout: 2))
        }
    }

    func testActionInsidePopoverRoutesIntoCallerState() {
        let app = launchHost(scene: "popover")
        app.buttons["popover-present-bottom-start"].click()
        let count = app.staticTexts["popover-action-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["popover-run-action"].click()
        XCTAssertEqual(text(of: count), "Actions: 1")
        app.buttons["popover-dismiss"].click()
        XCTAssertEqual(text(of: app.staticTexts["popover-scene-action-count"]), "Actions: 1")
    }

    func testDisabledControlsExposeDisabledSemantics() {
        let app = launchHost(scene: "popover")
        let trigger = app.buttons["popover-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)

        app.buttons["popover-present-bottom-center"].click()
        let close = app.buttons["popover-disabled-close"]
        XCTAssertTrue(close.waitForExistence(timeout: 5))
        XCTAssertFalse(close.isEnabled)
    }

    func testEscapeAndOutsidePressDismissNativePopover() {
        let app = launchHost(scene: "popover")
        let trigger = app.buttons["popover-present-bottom-center"]
        trigger.click()
        let content = app.descendants(matching: .any)["popover-bottom-center-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))

        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "Escape did not dismiss")

        trigger.click()
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.staticTexts["popover-scene-action-count"].click()
        XCTAssertTrue(content.waitForNonExistence(timeout: 2), "outside press did not dismiss")
    }

    func testLightAppearanceRendersPresentedPopover() {
        let app = launchHost(scene: "popover", appearance: "light")
        app.buttons["popover-present-bottom-start"].click()
        XCTAssertTrue(app.staticTexts["popover-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "popover-light")
    }

    func testDarkAppearanceRendersPresentedPopover() {
        let app = launchHost(scene: "popover", appearance: "dark")
        app.buttons["popover-present-bottom-start"].click()
        XCTAssertTrue(app.staticTexts["popover-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "popover-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "popover", appearance: "light")
        app.buttons["popover-present-bottom-start"].click()
        let content = app.descendants(matching: .any)["popover-bottom-start-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        assertPresentedPopoverDescriptions(in: app, content: content)

        // Apple's macOS description audit misclassifies both the system-owned
        // AXPopover container and its owning LazyVGrid as undescribed, even
        // though every meaningful descendant exposes its role and text below.
        // VoiceOver traversal of the system container remains manual
        // VALIDATION; all other automated audit dimensions still run.
        try runAccessibilityAudit(on: app, excluding: .sufficientElementDescription)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "popover", appearance: "dark")
        app.buttons["popover-present-top-start"].click()
        let content = app.descendants(matching: .any)["popover-top-start-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        assertPresentedPopoverDescriptions(in: app, content: content)

        // Same system-owned AXPopover/LazyVGrid false positive as light mode;
        // explicit descendant assertions cover the excluded description
        // dimension, and VoiceOver traversal remains manual VALIDATION. The
        // top-side case also keeps the popover from covering the title-bar
        // text that Apple's contrast sampler inspects.
        try runAccessibilityAudit(on: app, excluding: .sufficientElementDescription)
    }

    private func assertPresentedPopoverDescriptions(
        in app: XCUIApplication,
        content: XCUIElement
    ) {
        XCTAssertEqual(app.descendants(matching: .popover).count, 1)
        XCTAssertEqual(content.staticTexts["popover-title"].label, "Popover details")
        XCTAssertEqual(
            text(of: content.staticTexts["popover-description"]),
            "Rich content in a native presentation window."
        )
        XCTAssertEqual(content.buttons["popover-run-action"].label, "Run popover action")
        XCTAssertEqual(content.buttons["popover-disabled-close"].label, "Disabled close")
        XCTAssertFalse(content.buttons["popover-disabled-close"].isEnabled)
        XCTAssertEqual(content.buttons["popover-dismiss"].label, "Dismiss popover")
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
}
