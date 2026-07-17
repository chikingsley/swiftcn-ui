import XCTest

final class ResizableValidationTests: ValidationCase {
    func testEveryPanelAndHandleRendersAtItsInitialLayout() {
        let app = launchHost(scene: "resizable", height: 640)
        XCTAssertTrue(app.descendants(matching: .any)["resizable-left-pane"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.descendants(matching: .any)["resizable-right-pane"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["resizable-top-pane"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["resizable-bottom-pane"].exists)

        // SCResizableHandle has no accessibilityIdentifier hook (Resizable.swift's
        // builder consumes a value type, not a View); its accessibilityLabel is
        // the only stable handle so UI tests can query.
        XCTAssertTrue(handle(labeled: "Resize left and right panels", in: app).exists)
        XCTAssertTrue(handle(labeled: "Resize top and bottom panels", in: app).exists)
        XCTAssertTrue(handle(labeled: "Disabled resize handle", in: app).exists)

        XCTAssertEqual(text(of: app.staticTexts["resizable-left-percent"]), "Left: 50%")
        XCTAssertEqual(text(of: app.staticTexts["resizable-top-percent"]), "Top: 50%")
        attachWindowScreenshot(of: app, named: "resizable-light")
    }

    func testDraggingTheHorizontalHandleResizesBothPanels() {
        let app = launchHost(scene: "resizable", height: 640)
        let leftPane = app.descendants(matching: .any)["resizable-left-pane"]
        let rightPane = app.descendants(matching: .any)["resizable-right-pane"]
        XCTAssertTrue(leftPane.waitForExistence(timeout: 5))
        let initialLeftWidth = leftPane.frame.width
        XCTAssertEqual(initialLeftWidth, rightPane.frame.width, accuracy: 1, "panels must start equal")

        let handleElement = handle(labeled: "Resize left and right panels", in: app)
        XCTAssertTrue(handleElement.exists)
        let start = handleElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.click(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 60, dy: 0)))

        XCTAssertGreaterThan(
            percent(text(of: app.staticTexts["resizable-left-percent"])), 50,
            "dragging the handle right must grow the leading panel's real fraction"
        )
        XCTAssertGreaterThan(
            leftPane.frame.width, initialLeftWidth,
            "the leading panel's real frame must grow along with its layout fraction"
        )
        XCTAssertGreaterThan(leftPane.frame.width, rightPane.frame.width)
    }

    func testArrowKeysAdjustTheFocusedHorizontalHandle() {
        let app = launchHost(scene: "resizable", height: 640)
        let handleElement = handle(labeled: "Resize left and right panels", in: app)
        XCTAssertTrue(handleElement.waitForExistence(timeout: 5))
        handleElement.click()

        app.typeKey(.rightArrow, modifierFlags: [])
        XCTAssertTrue(waitForValue("Left: 55%", of: app.staticTexts["resizable-left-percent"]))

        app.typeKey(.leftArrow, modifierFlags: [])
        XCTAssertTrue(waitForValue("Left: 50%", of: app.staticTexts["resizable-left-percent"]))
        app.typeKey(.leftArrow, modifierFlags: [])
        XCTAssertTrue(waitForValue("Left: 45%", of: app.staticTexts["resizable-left-percent"]))
    }

    func testArrowKeysAdjustTheFocusedVerticalHandle() {
        let app = launchHost(scene: "resizable", height: 640)
        let handleElement = handle(labeled: "Resize top and bottom panels", in: app)
        XCTAssertTrue(handleElement.waitForExistence(timeout: 5))
        handleElement.click()

        app.typeKey(.downArrow, modifierFlags: [])
        XCTAssertTrue(waitForValue("Top: 55%", of: app.staticTexts["resizable-top-percent"]))

        app.typeKey(.upArrow, modifierFlags: [])
        XCTAssertTrue(waitForValue("Top: 50%", of: app.staticTexts["resizable-top-percent"]))
        app.typeKey(.upArrow, modifierFlags: [])
        XCTAssertTrue(waitForValue("Top: 45%", of: app.staticTexts["resizable-top-percent"]))
    }

    func testDoubleClickResetsTheHorizontalHandleToItsInitialLayout() {
        let app = launchHost(scene: "resizable", height: 640)
        let handleElement = handle(labeled: "Resize left and right panels", in: app)
        XCTAssertTrue(handleElement.waitForExistence(timeout: 5))

        let start = handleElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.click(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 60, dy: 0)))
        XCTAssertNotEqual(text(of: app.staticTexts["resizable-left-percent"]), "Left: 50%")

        handleElement.doubleClick()
        XCTAssertTrue(
            waitForValue("Left: 50%", of: app.staticTexts["resizable-left-percent"]),
            "a double click must reset to the layout captured at first appearance"
        )
    }

    func testDisabledHandleBlocksDraggingKeyboardAndDoubleClick() {
        let app = launchHost(scene: "resizable", height: 640)
        let handleElement = handle(labeled: "Disabled resize handle", in: app)
        XCTAssertTrue(handleElement.waitForExistence(timeout: 5))
        let leftPane = app.descendants(matching: .any)["resizable-disabled-left-pane"]
        let rightPane = app.descendants(matching: .any)["resizable-disabled-right-pane"]
        XCTAssertEqual(leftPane.frame.width, rightPane.frame.width, accuracy: 1)

        let start = handleElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.click(forDuration: 0.05, thenDragTo: start.withOffset(CGVector(dx: 60, dy: 0)))
        handleElement.click()
        app.typeKey(.rightArrow, modifierFlags: [])
        handleElement.doubleClick()

        XCTAssertEqual(
            text(of: app.staticTexts["resizable-disabled-left-percent"]), "Disabled left: 50%",
            "isDisabled must block drag, arrow-key, and double-click adjustment alike"
        )
        XCTAssertEqual(leftPane.frame.width, rightPane.frame.width, accuracy: 1)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "resizable", appearance: "dark", height: 640)
        XCTAssertTrue(app.descendants(matching: .any)["resizable-left-pane"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "resizable-dark")
    }

    // The sampler flags the large muted pane placeholders (mutedForeground on
    // the secondary pane surface computes to 7.02:1 light / 5.65:1 dark —
    // clearing WCAG AA), and reports the custom splitter handle — a labeled,
    // keyboard-operable Other with no standard control role — as "Unknown
    // role". SwiftUI exposes no splitter role to assign; the handle's label,
    // value, and keyboard operation are exercised by this suite's
    // interaction tests.
    private var paneAndHandleFindings: [KnownAuditFinding] {
        [
            KnownAuditFinding(descriptionContains: "Contrast", identifier: ""),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "resizable-left-pane"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "resizable-right-pane"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "resizable-top-pane"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "resizable-bottom-pane"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "resizable-disabled-left-pane"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "resizable-disabled-right-pane"),
            KnownAuditFinding(descriptionContains: "Unknown role", identifier: ""),
        ]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "resizable", appearance: "light", height: 640)
        XCTAssertTrue(app.descendants(matching: .any)["resizable-left-pane"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: paneAndHandleFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "resizable", appearance: "dark", height: 640)
        XCTAssertTrue(app.descendants(matching: .any)["resizable-left-pane"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: paneAndHandleFindings)
    }

    private func handle(labeled label: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", label)).firstMatch
    }

    private func percent(_ value: String) -> Int {
        Int(value.filter(\.isNumber)) ?? -1
    }

    private func waitForValue(
        _ value: String,
        of element: XCUIElement,
        timeout: TimeInterval = 3
    ) -> Bool {
        let expectation = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value == %@", value),
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }
}
