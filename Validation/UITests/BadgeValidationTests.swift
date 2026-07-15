import XCTest

final class BadgeValidationTests: ValidationCase {
    private let variants = ["default", "secondary", "destructive", "outline", "ghost", "link"]

    func testEveryVariantAndInvalidStateRenders() {
        let app = launchHost(scene: "badge")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))

        for variant in variants {
            XCTAssertTrue(
                app.staticTexts["badge-variant-\(variant)"].exists,
                "variant \(variant) is missing"
            )
        }
        XCTAssertTrue(app.staticTexts["badge-invalid"].exists)
        attachWindowScreenshot(of: app, named: "badge-light")
    }

    func testBadgeStyledButtonOwnsActivation() {
        let app = launchHost(scene: "badge")
        let button = app.buttons["badge-button"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.click()
        button.click()
        XCTAssertEqual(app.staticTexts["badge-activation-count"].label, "Activations: 2")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "badge", appearance: "dark")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "badge-dark")
    }

    func testAccessibilityAudit() throws {
        let app = launchHost(scene: "badge")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()
    }
}
