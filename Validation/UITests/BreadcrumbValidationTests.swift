import XCTest

final class BreadcrumbValidationTests: ValidationCase {
    func testComposedPartsRenderWithCurrentPageAndEllipsisSemantics() {
        let app = launchHost(scene: "breadcrumb")
        XCTAssertTrue(app.buttons["breadcrumb-home-link"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["breadcrumb-components-link"].exists)

        let page = app.staticTexts["breadcrumb-current-page"]
        XCTAssertTrue(page.exists)
        XCTAssertEqual(page.label, "Breadcrumb")
        XCTAssertEqual(page.value as? String, "Current page")

        let ellipsis = app.images["breadcrumb-ellipsis"]
        XCTAssertTrue(ellipsis.exists)
        XCTAssertEqual(ellipsis.label, "More breadcrumb items")
        XCTAssertTrue(app.groups["breadcrumb-composed"].exists)
        XCTAssertFalse(
            app.descendants(matching: .any)["breadcrumb-default-separator"].exists,
            "presentation-only separators must stay hidden from accessibility"
        )
        attachWindowScreenshot(of: app, named: "breadcrumb-light")
    }

    func testActionLinksRouteIntoCallerOwnedCounter() {
        let app = launchHost(scene: "breadcrumb")
        let home = app.buttons["breadcrumb-home-link"]
        XCTAssertTrue(home.waitForExistence(timeout: 5))

        home.click()
        XCTAssertEqual(text(of: app.staticTexts["breadcrumb-activation-count"]), "Activations: 1")
        XCTAssertEqual(text(of: app.staticTexts["breadcrumb-last-activated"]), "Last: home")

        app.buttons["breadcrumb-components-link"].click()
        XCTAssertEqual(text(of: app.staticTexts["breadcrumb-activation-count"]), "Activations: 2")
        XCTAssertEqual(text(of: app.staticTexts["breadcrumb-last-activated"]), "Last: components")
    }

    func testCollapsedConvenienceKeepsEndpointsAndCurrentPage() {
        let app = launchHost(scene: "breadcrumb")
        XCTAssertTrue(app.groups["breadcrumb-collapsed"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Root"].exists)
        XCTAssertTrue(app.images["More"].exists)

        let page = app.groups["breadcrumb-collapsed"].staticTexts["Breadcrumb"]
        XCTAssertTrue(page.exists)
        XCTAssertEqual(page.value as? String, "Current page")
        XCTAssertFalse(app.buttons["Docs"].exists, "collapsed middle items must not remain actionable")
    }

    func testDisabledLinkIsExposedAsDisabled() {
        let app = launchHost(scene: "breadcrumb")
        let link = app.buttons["breadcrumb-disabled-link"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        XCTAssertFalse(link.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "breadcrumb", appearance: "dark")
        XCTAssertTrue(app.buttons["breadcrumb-home-link"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "breadcrumb-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "breadcrumb", appearance: "light")
        XCTAssertTrue(app.buttons["breadcrumb-home-link"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "breadcrumb", appearance: "dark")
        XCTAssertTrue(app.buttons["breadcrumb-home-link"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
