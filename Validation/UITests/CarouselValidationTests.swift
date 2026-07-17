import XCTest

final class CarouselValidationTests: ValidationCase {
    func testHorizontalCarouselRendersAndProgrammaticCommandsRouteIntoExternalState() {
        let app = launchHost(scene: "carousel", height: 800)
        XCTAssertTrue(app.staticTexts["carousel-horizontal-echo"].waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-echo"]), "Horizontal current: 0")
        for index in 0..<5 {
            XCTAssertTrue(
                app.descendants(matching: .any)["carousel-horizontal-item-\(index)"].exists,
                "slide \(index) is missing"
            )
        }

        app.buttons["carousel-jump-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-echo"]), "Horizontal current: 3")
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-change-count"]), "Horizontal selection changes: 1")

        app.buttons["carousel-scroll-to-id-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-echo"]), "Horizontal current: 1")
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-change-count"]), "Horizontal selection changes: 2")
        attachWindowScreenshot(of: app, named: "carousel-light")
    }

    func testPreviousAndNextButtonsRouteIntoStateAndDisableAtBoundaries() {
        let app = launchHost(scene: "carousel", height: 800)
        let previous = app.buttons["carousel-horizontal-previous"]
        let next = app.buttons["carousel-horizontal-next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertFalse(previous.isEnabled, "previous must be disabled at the first slide")

        for expected in 1...4 {
            next.click()
            XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-echo"]), "Horizontal current: \(expected)")
        }
        XCTAssertFalse(next.isEnabled, "next must be disabled at the last slide")

        previous.click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-echo"]), "Horizontal current: 3")
    }

    func testIndicatorClickRoutesSelectionAndExposesSelectedTrait() {
        let app = launchHost(scene: "carousel", height: 800)
        let container = app.descendants(matching: .any)["carousel-horizontal"]
        let thirdIndicator = container.buttons["Slide 3 of 5"]
        XCTAssertTrue(thirdIndicator.waitForExistence(timeout: 5))
        XCTAssertFalse(thirdIndicator.isSelected)

        thirdIndicator.click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-horizontal-echo"]), "Horizontal current: 2")
        XCTAssertTrue(thirdIndicator.isSelected)
    }

    func testVerticalCarouselRoutesThroughItsOwnState() {
        let app = launchHost(scene: "carousel", height: 800)
        XCTAssertTrue(app.staticTexts["carousel-vertical-echo"].waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["carousel-vertical-echo"]), "Vertical current: 0")
        XCTAssertFalse(app.buttons["carousel-vertical-previous"].isEnabled)

        app.buttons["carousel-vertical-next"].click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-vertical-echo"]), "Vertical current: 1")

        app.buttons["carousel-vertical-previous"].click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-vertical-echo"]), "Vertical current: 0")
    }

    func testWrappingCarouselWrapsAtBothBoundaries() {
        let app = launchHost(scene: "carousel", height: 800)
        let previous = app.buttons["carousel-wrap-previous"]
        let next = app.buttons["carousel-wrap-next"]
        XCTAssertTrue(previous.waitForExistence(timeout: 5))
        XCTAssertTrue(previous.isEnabled, "wrapsNavigation must keep previous enabled at the first slide")

        previous.click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-wrap-echo"]), "Wrap current: 2")

        next.click()
        XCTAssertEqual(text(of: app.staticTexts["carousel-wrap-echo"]), "Wrap current: 0")
    }

    // SwiftUI's `.disabled(_:)` only ever narrows `isEnabled` — a nested
    // `.disabled(false)` from the canScroll flags cannot re-enable an
    // ancestor's `.disabled(true)` — so a disabled carousel disables its
    // navigation and indicators alike. A sibling writer's suspicion that the
    // nested clauses override the ancestor was disproven by this test's own
    // first run.
    func testDisabledCarouselDisablesNavigationAndIndicators() {
        let app = launchHost(scene: "carousel", height: 800)
        let container = app.descendants(matching: .any)["carousel-disabled"]
        let next = app.buttons["carousel-disabled-next"]
        XCTAssertTrue(next.waitForExistence(timeout: 5))
        XCTAssertFalse(next.isEnabled, "an ancestor .disabled(true) must disable Next")

        next.click()
        XCTAssertEqual(
            text(of: app.staticTexts["carousel-disabled-echo"]),
            "Disabled current: 0",
            "a disabled carousel must not route navigation into caller state"
        )

        XCTAssertFalse(
            container.buttons["Slide 3 of 3"].isEnabled,
            "indicators inherit the ancestor disable"
        )
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "carousel", appearance: "dark", height: 800)
        XCTAssertTrue(app.staticTexts["carousel-horizontal-echo"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "carousel-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "carousel", appearance: "light", height: 800)
        XCTAssertTrue(app.staticTexts["carousel-horizontal-echo"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "carousel", appearance: "dark", height: 800)
        XCTAssertTrue(app.staticTexts["carousel-horizontal-echo"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
