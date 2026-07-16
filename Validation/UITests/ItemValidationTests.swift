import XCTest

final class ItemValidationTests: ValidationCase {
    func testEveryVariantSizeMediaTreatmentAndRegionRenders() {
        let app = launchHost(scene: "item")
        XCTAssertTrue(app.staticTexts["item-default-title"].waitForExistence(timeout: 5))

        for identifier in [
            "item-variant-default", "item-variant-outline", "item-variant-muted", "item-compact",
        ] {
            XCTAssertTrue(app.groups[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertTrue(app.images["item-media-default"].exists)
        XCTAssertTrue(app.images["item-media-image"].exists)
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "item-media-icon-decorative").count,
            0,
            "decorative icon media must be hidden from accessibility"
        )
        XCTAssertTrue(app.staticTexts["item-header"].exists)
        XCTAssertTrue(app.staticTexts["item-footer"].exists)
        XCTAssertTrue(app.buttons["item-nested-action"].exists)
        attachWindowScreenshot(of: app, named: "item-light")
    }

    func testButtonLinkAndNestedActionsRouteToCallerOwnedState() {
        let app = launchHost(scene: "item")
        let count = app.staticTexts["item-activation-count"]
        let last = app.staticTexts["item-last-activated"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["item-nested-action"].click()
        XCTAssertEqual(text(of: last), "Last: nested-action")
        app.buttons["item-button-root"].click()
        XCTAssertEqual(text(of: last), "Last: button-root")
        app.links["item-link-root"].click()
        XCTAssertEqual(text(of: last), "Last: link-root")
        XCTAssertEqual(text(of: count), "Activations: 3")
    }

    func testLongDescriptionIsClampedToTwoLines() {
        let app = launchHost(scene: "item")
        let description = app.staticTexts["item-long-description"]
        let title = app.staticTexts["item-muted-title"]
        XCTAssertTrue(description.waitForExistence(timeout: 5))
        XCTAssertGreaterThan(description.frame.height, title.frame.height)
        XCTAssertLessThanOrEqual(description.frame.height, title.frame.height * 2.6)
    }

    func testDisabledItemRootIsExposedAsDisabled() {
        let app = launchHost(scene: "item")
        let button = app.buttons["item-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "item", appearance: "dark")
        XCTAssertTrue(app.staticTexts["item-default-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "item-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "item", appearance: "light")
        XCTAssertTrue(app.staticTexts["item-default-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "item", appearance: "dark")
        XCTAssertTrue(app.staticTexts["item-default-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
