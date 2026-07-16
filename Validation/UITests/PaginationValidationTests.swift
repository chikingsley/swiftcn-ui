import XCTest

final class PaginationValidationTests: ValidationCase {
    func testComposedPartsRenderAndRouteActions() {
        let app = launchHost(scene: "pagination")
        let previous = app.buttons["pagination-composed-previous"]
        let page = app.buttons["pagination-composed-page"]
        let next = app.buttons["pagination-composed-next"]
        XCTAssertTrue(previous.waitForExistence(timeout: 5))
        XCTAssertFalse(previous.isEnabled)
        XCTAssertTrue(page.exists)
        XCTAssertEqual(page.value as? String, "Current page")
        XCTAssertTrue(app.images["pagination-composed-ellipsis"].exists)
        XCTAssertTrue(next.exists)

        page.click()
        next.click()
        XCTAssertEqual(text(of: app.staticTexts["pagination-composed-echo"]), "Composed activations: 2")
        attachWindowScreenshot(of: app, named: "pagination-light")
    }

    func testWindowedPagerRoutesPreviousNextAndPageSelection() {
        let app = launchHost(scene: "pagination")
        let pager = app.groups["pagination-windowed"]
        let previous = pager.buttons["Go to previous page"]
        let next = pager.buttons["Go to next page"]
        XCTAssertTrue(previous.waitForExistence(timeout: 5))
        XCTAssertFalse(previous.isEnabled)
        XCTAssertTrue(next.isEnabled)
        XCTAssertEqual(text(of: app.staticTexts["pagination-page-echo"]), "Page: 1")

        next.click()
        XCTAssertEqual(text(of: app.staticTexts["pagination-page-echo"]), "Page: 2")
        XCTAssertEqual(text(of: app.staticTexts["pagination-callback-echo"]), "Callback page: 2")

        previous.click()
        XCTAssertEqual(text(of: app.staticTexts["pagination-page-echo"]), "Page: 1")
        XCTAssertFalse(previous.isEnabled)

        pager.buttons["Page 5"].click()
        XCTAssertEqual(text(of: app.staticTexts["pagination-page-echo"]), "Page: 5")
        XCTAssertEqual(text(of: app.staticTexts["pagination-callback-echo"]), "Callback page: 5")
        XCTAssertFalse(next.isEnabled)
    }

    func testBoundaryControlsClampWithoutDeliveringExtraCallbacks() {
        let app = launchHost(scene: "pagination")
        let pager = app.groups["pagination-windowed"]
        let previous = pager.buttons["Go to previous page"]
        XCTAssertTrue(previous.waitForExistence(timeout: 5))
        XCTAssertFalse(previous.isEnabled)
        XCTAssertEqual(text(of: app.staticTexts["pagination-page-echo"]), "Page: 1")
        XCTAssertEqual(text(of: app.staticTexts["pagination-callback-echo"]), "Callback page: 0")

        pager.buttons["Page 5"].click()
        let next = pager.buttons["Go to next page"]
        XCTAssertFalse(next.isEnabled)
        XCTAssertEqual(text(of: app.staticTexts["pagination-page-echo"]), "Page: 5")
        XCTAssertEqual(text(of: app.staticTexts["pagination-callback-echo"]), "Callback page: 5")
    }

    func testDisabledRootDisablesItsLink() {
        let app = launchHost(scene: "pagination")
        let link = app.buttons["pagination-disabled-link"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        XCTAssertFalse(link.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "pagination", appearance: "dark")
        XCTAssertTrue(
            app.groups["pagination-windowed"].buttons["Go to previous page"]
                .waitForExistence(timeout: 5)
        )
        attachWindowScreenshot(of: app, named: "pagination-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "pagination", appearance: "light")
        XCTAssertTrue(
            app.groups["pagination-windowed"].buttons["Go to previous page"]
                .waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "pagination", appearance: "dark")
        XCTAssertTrue(
            app.groups["pagination-windowed"].buttons["Go to previous page"]
                .waitForExistence(timeout: 5)
        )
        try runAccessibilityAudit(on: app)
    }
}
