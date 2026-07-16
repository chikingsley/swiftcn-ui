import XCTest

final class CardValidationTests: ValidationCase {
    func testEveryRegionSmallSizeAndConveniencesRender() {
        let app = launchHost(scene: "card")
        XCTAssertTrue(app.groups["card-composed"].waitForExistence(timeout: 5))

        for identifier in [
            "card-title", "card-description", "card-content-text",
            "card-small-title", "card-small-description", "card-compat-title",
        ] {
            XCTAssertTrue(app.staticTexts[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertTrue(app.groups["card-small"].exists, "small card is missing")
        XCTAssertTrue(app.groups["card-compat"].exists, "compatibility card is missing")
        attachWindowScreenshot(of: app, named: "card-light")
    }

    func testHeaderActionOccupiesTheTopTrailingGridCell() {
        let app = launchHost(scene: "card")
        let card = app.groups["card-composed"]
        let title = app.staticTexts["card-title"]
        let action = app.buttons["card-action-button"]
        XCTAssertTrue(card.waitForExistence(timeout: 5))
        XCTAssertTrue(title.exists)
        XCTAssertTrue(action.exists)

        XCTAssertEqual(action.frame.minY, title.frame.minY, accuracy: 4)
        XCTAssertGreaterThan(action.frame.minX, title.frame.maxX)
        XCTAssertEqual(card.frame.maxX - action.frame.maxX, 24, accuracy: 6)
    }

    func testFooterAndCompatibilityActionsRouteToCallerState() {
        let app = launchHost(scene: "card")
        let count = app.staticTexts["card-activation-count"]
        let last = app.staticTexts["card-last-activated"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["card-footer-cancel"].click()
        XCTAssertEqual(text(of: last), "Last: cancel")
        app.buttons["card-footer-deploy"].click()
        XCTAssertEqual(text(of: last), "Last: deploy")
        app.buttons["card-compat-action-button"].click()
        XCTAssertEqual(text(of: last), "Last: compat-action")
        app.buttons["card-action-button"].click()
        XCTAssertEqual(text(of: last), "Last: header-action")
        XCTAssertEqual(text(of: count), "Activations: 4")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "card", appearance: "dark")
        XCTAssertTrue(app.groups["card-composed"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "card-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "card", appearance: "light")
        XCTAssertTrue(app.groups["card-composed"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "card", appearance: "dark")
        XCTAssertTrue(app.groups["card-composed"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
