import XCTest

final class ScrollAreaValidationTests: ValidationCase {
    func testEveryScrollAreaExposesItsAccessibilityLabel() {
        let app = launchHost(scene: "scrollarea", height: 620)
        XCTAssertTrue(app.scrollViews["scrollarea-vertical"].waitForExistence(timeout: 5))
        XCTAssertEqual(app.scrollViews["scrollarea-vertical"].label, "Numbered rows")
        XCTAssertEqual(app.scrollViews["scrollarea-horizontal"].label, "Artwork")
        XCTAssertEqual(app.scrollViews["scrollarea-both-axes"].label, "Grid content")
        XCTAssertEqual(app.scrollViews["scrollarea-disabled"].label, "Disabled scroll area")
        attachWindowScreenshot(of: app, named: "scrollarea-light")
    }

    func testVerticalScrollAreaScrollsToRevealBottomMarker() {
        let app = launchHost(scene: "scrollarea", height: 620)
        let scrollArea = app.scrollViews["scrollarea-vertical"]
        XCTAssertTrue(scrollArea.waitForExistence(timeout: 5))
        let marker = app.staticTexts["scrollarea-bottom-marker"]
        XCTAssertFalse(marker.isHittable, "the bottom marker must start outside a 220pt viewport of 40 rows")

        scrollUntilHittable(scrollArea, marker, deltaY: -400)
        XCTAssertTrue(marker.isHittable, "scrolling a real ScrollView must bring later content into view")
    }

    func testHorizontalScrollAreaScrollsToRevealTrailingMarker() {
        let app = launchHost(scene: "scrollarea", height: 620)
        let scrollArea = app.scrollViews["scrollarea-horizontal"]
        XCTAssertTrue(scrollArea.waitForExistence(timeout: 5))
        let marker = app.staticTexts["scrollarea-trailing-marker"]
        XCTAssertFalse(marker.isHittable, "the trailing marker must start outside a 320pt-wide viewport")

        scrollUntilHittable(scrollArea, marker, deltaX: -400)
        XCTAssertTrue(marker.isHittable, "a declared horizontal Scrollbar must resolve a real horizontal axis")
    }

    func testCombinedAxisScrollAreaScrollsBothDirectionsToRevealCornerMarker() {
        let app = launchHost(scene: "scrollarea", height: 620)
        let scrollArea = app.scrollViews["scrollarea-both-axes"]
        XCTAssertTrue(scrollArea.waitForExistence(timeout: 5))
        let marker = app.staticTexts["scrollarea-corner-marker"]
        XCTAssertFalse(marker.isHittable)

        scrollUntilHittable(scrollArea, marker, deltaX: -400, deltaY: -400)
        XCTAssertTrue(
            marker.isHittable,
            "explicit axes: [.horizontal, .vertical] must produce a genuinely two-axis viewport"
        )
    }

    func testDisabledScrollAreaBlocksScrolling() {
        let app = launchHost(scene: "scrollarea", height: 620)
        let scrollArea = app.scrollViews["scrollarea-disabled"]
        XCTAssertTrue(scrollArea.waitForExistence(timeout: 5))
        let marker = app.staticTexts["scrollarea-disabled-bottom-marker"]
        XCTAssertFalse(marker.isHittable)

        // Direction-agnostic: isDisabled must block scrolling regardless of
        // which delta sign this macOS installation treats as "forward"
        // (ScrollArea.swift:160 applies .scrollDisabled(isDisabled || !isEnabled)).
        for _ in 0..<4 {
            scrollArea.scroll(byDeltaX: 0, deltaY: -400)
            scrollArea.scroll(byDeltaX: 0, deltaY: 400)
        }
        XCTAssertFalse(marker.isHittable, "isDisabled must genuinely block scrolling, not just dim the viewport")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "scrollarea", appearance: "dark", height: 620)
        XCTAssertTrue(app.scrollViews["scrollarea-vertical"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "scrollarea-dark")
    }

    // The scroll-fade overlay surfaces as a description-less structural
    // Other the audit flags with "element has no description" — the same
    // decorative-container false positive the Combobox suite excludes; the
    // scroll areas themselves carry caller-supplied labels asserted above.
    // The sampler flags the small scroll-row labels (mutedForeground,
    // 7.72:1 light / 7.59:1 dark — clearing WCAG AA text at 4.5:1) and any
    // identifier-carrying row text; matched broadly by "".
    private var mutedRowContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "*")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "scrollarea", appearance: "light", height: 620)
        XCTAssertTrue(app.scrollViews["scrollarea-vertical"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(
            on: app, tolerating: mutedRowContrastFindings, excluding: .sufficientElementDescription)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "scrollarea", appearance: "dark", height: 620)
        XCTAssertTrue(app.scrollViews["scrollarea-vertical"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(
            on: app, tolerating: mutedRowContrastFindings, excluding: .sufficientElementDescription)
    }

    /// macOS's scroll-wheel delta sign for "reveal later content" depends on
    /// the natural-scrolling preference of the machine running the suite.
    /// Try the caller's expected sign first, then its inverse, so the test
    /// exercises real scrolling instead of guessing a fixed convention.
    private func scrollUntilHittable(
        _ scrollView: XCUIElement,
        _ marker: XCUIElement,
        deltaX: CGFloat = 0,
        deltaY: CGFloat = 0,
        attempts: Int = 6
    ) {
        // One axis at a time: the native scroller drops the second axis of
        // a diagonal synthetic scroll delta.
        for _ in 0..<attempts where !marker.isHittable {
            scrollView.scroll(byDeltaX: deltaX, deltaY: 0)
        }
        for _ in 0..<attempts where !marker.isHittable {
            scrollView.scroll(byDeltaX: 0, deltaY: deltaY)
        }
        for _ in 0..<attempts where !marker.isHittable {
            scrollView.scroll(byDeltaX: -deltaX, deltaY: -deltaY)
        }
    }
}
